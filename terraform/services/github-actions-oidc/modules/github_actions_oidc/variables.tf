variable "mapping_settings" {
  type = map(object({
    target_list   = list(string)
    inline_policy = string
  }))
}
