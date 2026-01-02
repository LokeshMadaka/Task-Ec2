variable "myownec2info" {
  type = map(list(string))
  default = {
    subec2cidr = ["192.168.0.0/24","192.168.1.0/24","192.168.2.0/24"]
    subec2az=["ap-south-1a","ap-south-1b","ap-south-1c"]
    subec2name=["myownec2sub1","myownec2sub2","myownec2sub3"]
  }
}