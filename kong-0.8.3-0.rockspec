package = "kong"
version = "0.8.3-0"
supported_platforms = {"linux", "macosx"}
source = {
  url = "git://github.com/yp-creative/kong",
  branch = "develop"
}
description = {
  summary = "Kong is a scalable and customizable API Management Layer built on top of Nginx.",
  homepage = "http://getkong.org",
  license = "MIT"
}
dependencies = {
  "luasec ~> 0.5-2",

  "penlight ~> 1.3.2",
  "lua-resty-http ~> 0.07-0",
  "lua_uuid ~> 0.2.0-2",
  "lua_system_constants ~> 0.1.1-0",
  "luatz ~> 0.3-1",
  "yaml ~> 1.1.2-1",
  "lapis ~> 1.3.1-1",
  "stringy ~> 0.4-1",
  "lua-cassandra ~> 0.5.2",
  "pgmoon ~> 1.4.0",
  "multipart ~> 0.3-2",
  "lua-path ~> 0.2.3-1",
  "lua-cjson ~> 2.1.0-1",
  "ansicolors ~> 1.0.2-3",
  "lbase64 ~> 20120820-1",
  "lua-resty-iputils ~> 0.2.0-1",
  "mediator_lua ~> 1.1.2-0",

  "luasocket ~> 2.0.2-6",
  "lrexlib-pcre ~> 2.7.2-1",
  "lua-llthreads2 ~> 0.1.3-1",
  "luacrypto >= 0.3.2-1",
  "luasyslog >= 1.0.0-2",
  "lua_pack ~> 1.0.4-0"
}
build = {
  type = "builtin",
  modules = {
    ["kong"] = "kong/kong.lua",

    ["classic"] = "kong/vendor/classic.lua",
    ["lapp"] = "kong/vendor/lapp.lua",

    ["kong.meta"] = "kong/meta.lua",
    ["kong.constants"] = "kong/constants.lua",
    ["kong.singletons"] = "kong/singletons.lua",

    ["kong.cli.utils.logger"] = "kong/cli/utils/logger.lua",
    ["kong.cli.utils.ssl"] = "kong/cli/utils/ssl.lua",
    ["kong.cli.utils.input"] = "kong/cli/utils/input.lua",
    ["kong.cli.utils.services"] = "kong/cli/utils/services.lua",
    ["kong.cli.cmds.config"] = "kong/cli/cmds/config.lua",
    ["kong.cli.cmds.quit"] = "kong/cli/cmds/quit.lua",
    ["kong.cli.cmds.stop"] = "kong/cli/cmds/stop.lua",
    ["kong.cli.cmds.start"] = "kong/cli/cmds/start.lua",
    ["kong.cli.cmds.reload"] = "kong/cli/cmds/reload.lua",
    ["kong.cli.cmds.restart"] = "kong/cli/cmds/restart.lua",
    ["kong.cli.cmds.version"] = "kong/cli/cmds/version.lua",
    ["kong.cli.cmds.status"] = "kong/cli/cmds/status.lua",
    ["kong.cli.cmds.migrations"] = "kong/cli/cmds/migrations.lua",
    ["kong.cli.cmds.cluster"] = "kong/cli/cmds/cluster.lua",
    ["kong.cli.services.base_service"] = "kong/cli/services/base_service.lua",
    ["kong.cli.services.dnsmasq"] = "kong/cli/services/dnsmasq.lua",
    ["kong.cli.services.serf"] = "kong/cli/services/serf.lua",
    ["kong.cli.services.nginx"] = "kong/cli/services/nginx.lua",

    ["kong.api.app"] = "kong/api/app.lua",
    ["kong.api.api_helpers"] = "kong/api/api_helpers.lua",
    ["kong.api.crud_helpers"] = "kong/api/crud_helpers.lua",
    ["kong.api.routes.kong"] = "kong/api/routes/kong.lua",
    ["kong.api.routes.apis"] = "kong/api/routes/apis.lua",
    ["kong.api.routes.consumers"] = "kong/api/routes/consumers.lua",
    ["kong.api.routes.plugins"] = "kong/api/routes/plugins.lua",
    ["kong.api.routes.cache"] = "kong/api/routes/cache.lua",
    ["kong.api.routes.cluster"] = "kong/api/routes/cluster.lua",

    ["kong.tools.io"] = "kong/tools/io.lua",
    ["kong.tools.utils"] = "kong/tools/utils.lua",
    ["kong.tools.faker"] = "kong/tools/faker.lua",
    ["kong.tools.syslog"] = "kong/tools/syslog.lua",
    ["kong.tools.ngx_stub"] = "kong/tools/ngx_stub.lua",
    ["kong.tools.printable"] = "kong/tools/printable.lua",
    ["kong.tools.cluster"] = "kong/tools/cluster.lua",
    ["kong.tools.responses"] = "kong/tools/responses.lua",
    ["kong.tools.timestamp"] = "kong/tools/timestamp.lua",
    ["kong.tools.http_client"] = "kong/tools/http_client.lua",
    ["kong.tools.database_cache"] = "kong/tools/database_cache.lua",
    ["kong.tools.config_defaults"] = "kong/tools/config_defaults.lua",
    ["kong.tools.config_loader"] = "kong/tools/config_loader.lua",

    ["kong.core.handler"] = "kong/core/handler.lua",
    ["kong.core.certificate"] = "kong/core/certificate.lua",
    ["kong.core.resolver"] = "kong/core/resolver.lua",
    ["kong.core.plugins_iterator"] = "kong/core/plugins_iterator.lua",
    ["kong.core.hooks"] = "kong/core/hooks.lua",
    ["kong.core.reports"] = "kong/core/reports.lua",
    ["kong.core.cluster"] = "kong/core/cluster.lua",
    ["kong.core.events"] = "kong/core/events.lua",
    ["kong.core.error_handlers"] = "kong/core/error_handlers.lua",

    ["kong.dao.errors"] = "kong/dao/errors.lua",
    ["kong.dao.schemas_validation"] = "kong/dao/schemas_validation.lua",
    ["kong.dao.schemas.apis"] = "kong/dao/schemas/apis.lua",
    ["kong.dao.schemas.nodes"] = "kong/dao/schemas/nodes.lua",
    ["kong.dao.schemas.consumers"] = "kong/dao/schemas/consumers.lua",
    ["kong.dao.schemas.plugins"] = "kong/dao/schemas/plugins.lua",
    ["kong.dao.base_db"] = "kong/dao/base_db.lua",
    ["kong.dao.cassandra_db"] = "kong/dao/cassandra_db.lua",
    ["kong.dao.postgres_db"] = "kong/dao/postgres_db.lua",
    ["kong.dao.dao"] = "kong/dao/dao.lua",
    ["kong.dao.model_factory"] = "kong/dao/model_factory.lua",
    ["kong.dao.migrations.cassandra"] = "kong/dao/migrations/cassandra.lua",
    ["kong.dao.migrations.postgres"] = "kong/dao/migrations/postgres.lua",

    ["kong.plugins.base_plugin"] = "kong/plugins/base_plugin.lua",

    ["kong.plugins.oauth2.migrations.cassandra"] = "kong/plugins/oauth2/migrations/cassandra.lua",
    ["kong.plugins.oauth2.migrations.postgres"] = "kong/plugins/oauth2/migrations/postgres.lua",
    ["kong.plugins.oauth2.handler"] = "kong/plugins/oauth2/handler.lua",
    ["kong.plugins.oauth2.access"] = "kong/plugins/oauth2/access.lua",
    ["kong.plugins.oauth2.hooks"] = "kong/plugins/oauth2/hooks.lua",
    ["kong.plugins.oauth2.schema"] = "kong/plugins/oauth2/schema.lua",
    ["kong.plugins.oauth2.daos"] = "kong/plugins/oauth2/daos.lua",
    ["kong.plugins.oauth2.api"] = "kong/plugins/oauth2/api.lua",

    ["kong.plugins.log-serializers.basic"] = "kong/plugins/log-serializers/basic.lua",
    ["kong.plugins.log-serializers.runscope"] = "kong/plugins/log-serializers/runscope.lua",

    ["kong.plugins.file-log.handler"] = "kong/plugins/file-log/handler.lua",
    ["kong.plugins.file-log.schema"] = "kong/plugins/file-log/schema.lua",

    ["kong.plugins.rate-limiting.migrations.cassandra"] = "kong/plugins/rate-limiting/migrations/cassandra.lua",
    ["kong.plugins.rate-limiting.migrations.postgres"] = "kong/plugins/rate-limiting/migrations/postgres.lua",
    ["kong.plugins.rate-limiting.handler"] = "kong/plugins/rate-limiting/handler.lua",
    ["kong.plugins.rate-limiting.schema"] = "kong/plugins/rate-limiting/schema.lua",
    ["kong.plugins.rate-limiting.dao.cassandra"] = "kong/plugins/rate-limiting/dao/cassandra.lua",
    ["kong.plugins.rate-limiting.dao.postgres"] = "kong/plugins/rate-limiting/dao/postgres.lua",

    ["kong.plugins.correlation-id.handler"] = "kong/plugins/correlation-id/handler.lua",
    ["kong.plugins.correlation-id.schema"] = "kong/plugins/correlation-id/schema.lua",

    ["kong.plugins.syslog.handler"] = "kong/plugins/syslog/handler.lua",
    ["kong.plugins.syslog.schema"] = "kong/plugins/syslog/schema.lua",

    ["kong.yop.cache"] = "kong/yop/cache.lua",
    ["kong.yop.http_client"] = "kong/yop/http_client.lua",
    ["kong.yop.response"] = "kong/yop/response.lua",
    ["kong.yop.dkjson"] = "kong/yop/dkjson.lua",
    ["kong.yop.security_center"] = "kong/yop/security_center.lua",
    ["kong.plugins.yop.interceptor.auth"] = "kong/plugins/yop/interceptor/auth.lua",
    ["kong.plugins.yop.interceptor.decrypt"] = "kong/plugins/yop/interceptor/decrypt.lua",
    ["kong.plugins.yop.interceptor.default_value"] = "kong/plugins/yop/interceptor/default_value.lua",
    ["kong.plugins.yop.interceptor.http_method"] = "kong/plugins/yop/interceptor/http_method.lua",
    ["kong.plugins.yop.interceptor.initialize_ctx"] = "kong/plugins/yop/interceptor/initialize_ctx.lua",
    ["kong.plugins.yop.interceptor.load_balance"] = "kong/plugins/yop/interceptor/load_balance.lua",
    ["kong.plugins.yop.interceptor.request_transformer"] = "kong/plugins/yop/interceptor/request_transformer.lua",
    ["kong.plugins.yop.interceptor.request_validator"] = "kong/plugins/yop/interceptor/request_validator.lua",
    ["kong.plugins.yop.interceptor.whitelist"] = "kong/plugins/yop/interceptor/whitelist.lua",
    ["kong.plugins.yop.interceptor.validate_sign"] = "kong/plugins/yop/interceptor/validate_sign.lua",
    ["kong.plugins.yop.handler"] = "kong/plugins/yop/handler.lua",
    ["kong.plugins.yop.schema"] = "kong/plugins/yop/schema.lua"
  },
  install = {
    conf = { "kong.yml" },
    bin = { "bin/kong" }
  }
}
