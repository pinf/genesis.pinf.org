{
	"extends": %%EXTENDS%%,
	"name": "%%BASENAME%%",
	"config": {
		"genesis.pinf.org/0": {
			"uid": "%%UID%%",
			"basename": "%%BASENAME%%",
			"label": "%%BASENAME%%",
			"description": "",
			"issues.url": "",
			"version": "0.0.0"
		},
		"%%UID%%/0": {
			"$to": "%%BASENAME%%",
			"source": {
				"catalog": "{{$from.pgs-distribution.distributions.pub.url}}/catalog.json"
			},
			"runtime": {
				"homepage": "{{$from.pgs-browser.homepage}}"
			}
		}
	}
}