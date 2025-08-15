variable "graphviz_layer_arn" {
  description = "Optional ARN of a public Graphviz Lambda Layer to attach. If null/empty, a local Graphviz layer will be built and published."
  type        = string
  default     = null
}
