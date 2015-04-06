{
	"extends": %%EXTENDS%%,
	"name": "%%BASENAME%%",
	"config": {
		"genesis.pinf.org/0": {
			"$to": "pgs",
			"programs": {
				".pgs": {
					"location": "./.pgs/program.json",
					"config": {
						"github.com/pinf/org.pinf.lib/0": {
							"plugin": "boot"
						}
					}
				}
			},
			"uid": "%%UID%%",
			"basename": "%%BASENAME%%",
			"label": "%%BASENAME%%",
			"description": "",
			"issues.url": "",
			"version": "0.0.0"
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