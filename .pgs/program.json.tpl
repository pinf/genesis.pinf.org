{
	"$extends": %%EXTENDS%%,
	"name": "%%BASENAME%%",
	"config": {
		"%%BASENAME%%/0": {
			"$to": "pgs",
			"uid": "%%UID%%",
			"basename": "%%BASENAME%%",
			"label": "%%BASENAME%%",
			"description": "",
			"issues.url": "",
			"version": "0.0.0",
			"programs": {
				".pgs": {
					"location": "./.pgs/program.json",
					"config": {
						"genesis.pinf.org/0": {
							"for": "boot"
						}
					}
				}
			}
		},
		"%%UID%%/0": {
			"$to": "%%BASENAME%%",
			"dist": {
				"catalog": "{{$from.pgs-distribution.distributions.dist.url}}/catalog.json"
			},
			"run": {
				"homepage": "{{$from.pgs-browser.homepage}}"
			}
		}
	}
}