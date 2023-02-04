variable "env_name" {
  type        = string
  description = "デプロイ先の環境名"
}

variable "workspaces" {
  type = map(object({
    variable_set_id_list = list(string)
  }))
  description = "生成するワークスペース"
}
