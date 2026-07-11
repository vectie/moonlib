///|
pub(all) enum WorkStatus {
  Proposed
  Ready
  Active
  Waiting
  Blocked
  Review
  Accepted
  Failed
  Cancelled
  Superseded
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn WorkStatus::id(self : WorkStatus) -> String {
  match self {
    Proposed => "proposed"
    Ready => "ready"
    Active => "active"
    Waiting => "waiting"
    Blocked => "blocked"
    Review => "review"
    Accepted => "accepted"
    Failed => "failed"
    Cancelled => "cancelled"
    Superseded => "superseded"
  }
}

///|
pub fn WorkStatus::is_terminal(self : WorkStatus) -> Bool {
  match self {
    Accepted | Failed | Cancelled | Superseded => true
    _ => false
  }
}

///|
pub(all) struct ArtifactRef {
  artifact_id : String
  producer : String
  digest : String
  uri : String
  authority : String
  recorded_at : String
} derive(Debug, Eq, ToJson)

///|
pub fn ArtifactRef::quality_issues(self : ArtifactRef) -> Array[String] {
  let issues : Array[String] = []
  if self.artifact_id.trim().is_empty() {
    issues.push("artifact_id is required")
  }
  if self.producer.trim().is_empty() {
    issues.push("artifact producer is required")
  }
  if self.digest.trim().is_empty() {
    issues.push("artifact digest is required")
  }
  if self.uri.trim().is_empty() {
    issues.push("artifact uri is required")
  }
  if self.authority.trim().is_empty() {
    issues.push("artifact authority is required")
  }
  issues
}

///|
pub(all) struct WorkItem {
  work_item_id : String
  declaration_id : String
  product_id : String
  status : WorkStatus
  depends_on : Array[String]
  input_artifacts : Array[ArtifactRef]
  output_artifacts : Array[ArtifactRef]
  requested_authority : AuthorityClass
  attempt_count : Int
  blocker : String
} derive(Debug, Eq, ToJson)

///|
pub(all) struct WorkGraph {
  graph_id : String
  book_id : String
  declaration_revision : String
  items : Array[WorkItem]
  recorded_at : String
} derive(Debug, Eq, ToJson)

///|
fn WorkGraph::item_ids(self : WorkGraph) -> Array[String] {
  self.items.map(item => item.work_item_id)
}

///|
fn WorkGraph::has_cycle(self : WorkGraph) -> Bool {
  let ids = self.item_ids()
  let processed : Array[String] = []
  for ;; {
    let before = processed.length()
    for item in self.items {
      if !processed.contains(item.work_item_id) {
        let mut ready = true
        for dependency in item.depends_on {
          if ids.contains(dependency) && !processed.contains(dependency) {
            ready = false
          }
        }
        if ready {
          processed.push(item.work_item_id)
        }
      }
    }
    if processed.length() == self.items.length() {
      break
    }
    if processed.length() == before {
      break
    }
  }
  processed.length() != self.items.length()
}

///|
pub fn WorkGraph::quality_issues(self : WorkGraph) -> Array[String] {
  let issues : Array[String] = []
  if self.graph_id.trim().is_empty() {
    issues.push("graph_id is required")
  }
  if self.book_id.trim().is_empty() {
    issues.push("book_id is required")
  }
  if self.declaration_revision.trim().is_empty() {
    issues.push("declaration_revision is required")
  }
  let ids : Array[String] = []
  for item in self.items {
    if item.work_item_id.trim().is_empty() {
      issues.push("work_item_id is required")
    } else if ids.contains(item.work_item_id) {
      issues.push("duplicate work_item_id: \{item.work_item_id}")
    } else {
      ids.push(item.work_item_id)
    }
    if item.declaration_id.trim().is_empty() {
      issues.push("declaration_id is required for \{item.work_item_id}")
    }
    if item.product_id.trim().is_empty() {
      issues.push("product_id is required for \{item.work_item_id}")
    }
    if item.attempt_count < 0 {
      issues.push("attempt_count cannot be negative for \{item.work_item_id}")
    }
  }
  for item in self.items {
    for dependency in item.depends_on {
      if dependency == item.work_item_id {
        issues.push("work item cannot depend on itself: \{item.work_item_id}")
      } else if !ids.contains(dependency) {
        issues.push("unknown dependency \{dependency} for \{item.work_item_id}")
      }
    }
  }
  if self.has_cycle() {
    issues.push("work graph contains a dependency cycle")
  }
  issues
}

///|
pub fn WorkGraph::runnable_item_ids(self : WorkGraph) -> Array[String] {
  let accepted : Array[String] = []
  for item in self.items {
    if item.status == Accepted {
      accepted.push(item.work_item_id)
    }
  }
  let runnable : Array[String] = []
  for item in self.items {
    if item.status == Proposed || item.status == Ready || item.status == Waiting {
      let mut dependencies_accepted = true
      for dependency in item.depends_on {
        if !accepted.contains(dependency) {
          dependencies_accepted = false
        }
      }
      if dependencies_accepted {
        runnable.push(item.work_item_id)
      }
    }
  }
  runnable
}
