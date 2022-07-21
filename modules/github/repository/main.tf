resource "github_repository" "repo" {
  allow_auto_merge       = var.allow_auto_merge
  allow_merge_commit     = var.allow_merge_commit
  allow_rebase_merge     = var.allow_rebase_merge
  allow_squash_merge     = var.allow_squash_merge
  archived               = var.archived
  archive_on_destroy     = var.archive_on_destroy
  auto_init              = var.auto_init
  delete_branch_on_merge = var.delete_branch_on_merge
  description            = var.description
  gitignore_template     = var.gitignore_template
  has_downloads          = var.has_downloads
  has_issues             = var.has_issues
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  homepage_url           = var.homepage_url
  license_template       = var.license_template
  is_template            = var.is_template
  name                   = var.name
  private                = var.private
  topics                 = var.topics
  visibility             = var.visibility
  vulnerability_alerts   = var.vulnerability_alerts

  template {
    owner                = var.template_owner
    repository           = var.template_repository
  }
}
