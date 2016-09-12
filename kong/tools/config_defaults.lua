return {
  ["nginx_working_dir"] = { type = "string", default = "/usr/local/kong" },
  ["yop_hessian_url"] = { type = "string", default = "http://yop.core.3g:8080/yop-hessian" },
  ["yop_center_url"] = { type = "string", default = "http://yop.center.3g/yop-center" },
  ["dns_resolver"] = { type = "string", default = "8.8.8.8" },
  ["yop_cache_expired_seconds"] = { type = "number", default = 300 },
  ["proxy_listen"] = { type = "string", default = "0.0.0.0:8000" },
  ["proxy_listen_ssl"] = { type = "string", default = "0.0.0.0:8443" },
  ["admin_api_listen"] = { type = "string", default = "0.0.0.0:8001" },
  ["cluster_listen"] = { type = "string", default = "0.0.0.0:7946" },
  ["cluster_listen_rpc"] = { type = "string", default = "127.0.0.1:7373" },
  ["cluster"] = {
    type = "table",
    content = {
      ["auto-join"] = { type = "boolean", default = true },
      ["advertise"] = { type = "string", nullable = true },
      ["encrypt"] = { type = "string", nullable = true },
      ["profile"] = { type = "string", default = "wan", enum = { "wan", "lan", "local" } },
      ["ttl_on_failure"] = { type = "number", default = 3600, min = 60 }
    }
  },
  ["ssl_cert_path"] = { type = "string", nullable = true },
  ["ssl_key_path"] = { type = "string", nullable = true },
  ["memory_cache_size"] = { type = "number", default = 128, min = 32 },
  ["nginx"] = { type = "string", nullable = true }
}
