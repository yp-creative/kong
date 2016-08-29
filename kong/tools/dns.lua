local dns_client

--- Load and setup the DNS client according to the provided configuration.
-- @param conf (table) Kong configuration
-- @return the initialized `dns.client` module, or nil+error if it was already initialized
local setup_client = function(conf)
  if dns_client then
    return nil, "DNS client already initialized"
  else
    dns_client = require "dns.client"
  end

  conf = conf or {}
  local hosts = conf.dns_hostsfile      -- filename
  local servers = conf.dns_resolver     -- array with ipv4[:port] entries
  
  -- servers must be reformatted as name/port sub-arrays
  if servers then
    for i, server in ipairs(servers) do
      local ip, port = server:match("^([^:]+)%:*(%d*)$")
      servers[i] = { ip, tonumber(port) or 53 }   -- inserting port if omitted
    end
  end
    
  local opts = {
    hosts = hosts,
    resolv_conf = nil,
    max_resolvers = 50,
    nameservers = servers,
    retrans = 5,
    timeout = 2000,
    no_recurse = false,
  }
  
  assert(dns_client.init(opts))

  return dns_client
end

--- implements co-socket connect method with dns resolution by Kong internals.
-- If the name resolves to SRV records, the port returned by the DNS server will override
-- the one provided.
-- @param sock the socket to connect
-- @param host hostname to connect to
-- @param port port to connect to
-- @param opts the options table
-- @return success, or nil + error
local connect = function(sock, host, port, opts)
  local target_ip, target_port = dns_client.toip(host, port)
  if not target_ip then return nil, target_port end
  return sock:connect(target_ip, target_port, opts)
end

return {
  setup_client = setup_client,
  connect = connect,
}

