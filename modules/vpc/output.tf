output "vpc_id" {
    value = aws_vpc.dhyey_vpc.id
}

output "public_subnet_ids" {
    value = {
        # for subnet in aws_subnet.public_subnet : subnet.id => subnet.id
        "Public-subnet-1" = aws_subnet.public_subnet[0].id
        "Public-subnet-2" = aws_subnet.public_subnet[1].id
    }
}

output "private_subnet_ids" {
    value = {
        # for subnet in aws_subnet.public_subnet : subnet.id => subnet.id
        "Private-subnet-1" = aws_subnet.private_subnet[0].id
        "Private-subnet-2" = aws_subnet.private_subnet[1].id
    }
}