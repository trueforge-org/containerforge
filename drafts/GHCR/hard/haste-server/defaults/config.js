{
  "host": "0.0.0.0",
  "port": 7777,
  "keyLength": 10,
  "maxLength": 400000,
  "staticMaxAge": 86400,
  "recompressStaticAssets": false,
  "logging": {
    "level": "verbose",
    "type": "Console",
    "colorize": true
  },
  "keyGenerator": {
    "type": "phonetic"
  },
  "rateLimits": {
    "whitelist": [],
    "blacklist": [],
    "categories": {
      "normal": {
        "totalRequests": 500,
        "every": 60000
      }
    }
  },
  "storage": {
    "type": "file",
    "path": "/config/data"
  }
}
