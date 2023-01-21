variable "env_name" {
  type = string
  description = "デプロイ先の環境名"
}

variable "workspaces" {
  type = map
  description = "生成するワークスペース"
}
