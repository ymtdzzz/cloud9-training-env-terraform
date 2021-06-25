variable "user_count" {
    type = number
}

variable "name" {
    type = string
}

resource "aws_iam_user" "this" {
    count = var.user_count
    name = "${var.name}-${count.index}"
    path = "/"
    force_destroy = true
}

resource "aws_iam_user_login_profile" "this" {
    count = var.user_count
    user = "${var.name}-${count.index}"
    password_reset_required = false
    password_length = 20
    pgp_key = "keybase:ymatsuda"
}

resource "aws_iam_group" "this" {
    name = var.name
}

resource "aws_iam_group_policy_attachment" "this" {
    group = aws_iam_group.this.name
    policy_arn = "arn:aws:iam::aws:policy/AWSCloud9EnvironmentMember"
}

resource "aws_iam_group_membership" "this" {
    count = var.user_count
    name = var.name

    users = [
        "${var.name}-${count.index}"
    ]

    group = aws_iam_group.this.name

    depends_on = [
        aws_iam_user.this
    ]
}

output "encrypted_password" {
    value = join("\n", aws_iam_user_login_profile.this.*.encrypted_password)
}

output "user" {
    value = join("\n", aws_iam_user.this.*.name)
}
