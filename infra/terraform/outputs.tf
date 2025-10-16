output "control_plane_ips" { value = module.nodes.control_plane_public_ips }
output "worker_ips"        { value = module.nodes.worker_public_ips }