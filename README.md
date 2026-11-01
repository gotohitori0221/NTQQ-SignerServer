# NTQQ-PureSignServer

NTQQ 签名服务（纯本地实现），对应 Linux QQ `3.2.34-53644` 的 `sec-sign` 签名算法。

本仓库的 `pure-53644` 分支为**独立实现版本**：不依赖 QQ 客户端进程、外部 DLL 或在线接口，签名逻辑全部在 C# 内部完成，启动即可使用。

## 特性

- 纯本地计算 `sec_sign` / `sec_token` / `sec_extra`，无外部依赖
- 兼容 `Lagrange.Milky` / `Yogurt` / `EulerOneBot` 等 Milky/OneBot 实现的签名请求格式
- 内置命令白名单（支持 `xxx.*` 后缀通配）与可选 Token 鉴权
- 单文件、自包含发布（`win-x64` / `linux-x64`），可选 IL 混淆与 UPX 压缩
- 自带一致性自检（`verify.bat`），对本仓库 `parity_reference.jsonl` 中的参考样本逐条比对

## 目录结构

| 文件 | 说明 |
| --- | --- |
| `Program.cs` | 全部服务端与签名实现 |
| `appsettings.json` | 运行配置（监听地址、鉴权、命令白名单） |
| `parity_reference.jsonl` | 自检参考样本（`body` / `us` / `sec_sign` / `sec_extra`） |
| `build.bat` | 一键构建、混淆、打包 win-x64 与 linux-x64 单文件 |
| `verify.bat` | 编译 `SELF` 自检版本并运行一致性测试 |
| `obfuscar.xml` | Obfuscar 混淆配置 |
| `upx.exe` | 可选的 UPX 压缩工具 |
| `sign.js` | 签名算法的参考实现（JavaScript） |

## 构建

需要 .NET 10 / 9 / 8 SDK 任一（`build.bat` 会自动探测可用的目标框架）。

```bat
:: 仅编译 + 自检
verify.bat

:: 完整构建：Release -> 可选混淆 -> 单文件自包含发布
build.bat
```

产物路径：

- Windows：`bin\Release\<TFM>\win-x64\publish\NTQQ-PureSignServer.exe`
- Linux：`bin\Release\<TFM>\linux-x64\publish\NTQQ-PureSignServer`

## 运行

```bat
NTQQ-PureSignServer.exe                 :: 读取 appsettings.json
NTQQ-PureSignServer.exe 8080            :: 覆盖端口
NTQQ-PureSignServer.exe 8080 0.0.0.0    :: 覆盖端口 + 监听地址
```

首次运行若缺少 `appsettings.json`，会自动生成默认配置文件。

## 配置

```json
{
  "Server": { "Host": "127.0.0.1", "Port": 8080 },
  "Auth": {
    "EnableTokenAuth": false,
    "Tokens": [ "your_token_here" ]
  },
  "Whitelist": {
    "EnableCmdWhitelist": true,
    "CmdWhitelist": [ "ConnAuthSvr.fast_qq_login", "trpc.*" ]
  }
}
```

- `Server.Host` / `Server.Port`：监听地址与端口，默认 `127.0.0.1:8080`
- `Auth.EnableTokenAuth`：开启后请求需带 `Authorization: Bearer <token>` 或 `?token=<token>`
- `Whitelist.EnableCmdWhitelist`：开启后仅放行 `CmdWhitelist` 中的命令，以 `*` 结尾表示前缀匹配

## 接口

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| GET / POST | `/api/sign/sec-sign/appinfo_v2` | 返回 `appinfo_v2`（供客户端获取签名配置） |
| GET / POST | `/api/sign/sec-sign` | 主签名接口 |
| GET / POST | `/sign` | 同上，兼容旧路径 |

请求参数（GET 走 Query，POST 走 JSON Body 或 Query）：

| 字段 | 说明 |
| --- | --- |
| `cmd` / `command` | 命令名，用于白名单校验 |
| `uin` | QQ 号，仅用于日志 |
| `body` / `src` | 待签名数据的十六进制串 |
| `qua` / `ver` | 客户端 QUA，缺省使用内置值 |

响应：

```json
{
  "code": 0,
  "message": null,
  "value": {
    "sec_sign": "...",
    "sec_token": "...",
    "sec_extra": "..."
  }
}
```

协议端签名地址填写 `http://127.0.0.1:8080/api/`。

## 自检

```bat
verify.bat
```

编译带 `SELF` 宏的版本，并以 `parity_reference.jsonl` 中的参考结果逐条比对，输出 `OK=... BAD=...`。

## 许可证

本分支保留仓库根目录的 `LICENSE`，版权与使用条款以该文件为准。

> 本项目仅用于学习、研究与个人协议端开发交流，请勿用于任何违反法律法规或平台服务条款的场景。
