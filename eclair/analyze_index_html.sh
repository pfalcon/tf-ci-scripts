#!/bin/bash
#
# Copyright (c) 2022 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Template to produce index.html for the "full" build.

cat <<EOF >index.html
<html>
<body>
<h1>MISRA reports</h1>

<p>
TF-A Config: ${TF_CONFIG}<br />
CI Build: <a href="${BUILD_URL}">${BUILD_URL}</a>
</p>

Reports:
<ul>
<li><a href='ECLAIR/full_html/by_service.html#service/first_file&kind{"select":true,"selection":{"hiddenAreaKinds":[],"hiddenSubareaKinds":[],"show":true,"selector":{"enabled":true,"negated":false,"kind":1,"children":[{"enabled":true,"negated":false,"kind":0,"domain":"strictness","inputs":[{"enabled":true,"text":"mandatory"}]},{"enabled":true,"negated":false,"kind":0,"domain":"kind","inputs":[{"enabled":true,"text":"violation"}]}]}}}'>Mandatory rules - violations</a>
<li><a href='ECLAIR/full_html/by_service.html#service/first_file&kind{"select":true,"selection":{"hiddenAreaKinds":[],"hiddenSubareaKinds":[],"show":true,"selector":{"enabled":true,"negated":false,"kind":1,"children":[{"enabled":true,"negated":false,"kind":0,"domain":"strictness","inputs":[{"enabled":true,"text":"mandatory"}]},{"enabled":true,"negated":false,"kind":0,"domain":"kind","inputs":[{"enabled":true,"text":"violation"},{"enabled":true,"text":"caution"}]}]}}}'>Mandatory rules - violations & cautions</a>
<li><a href='ECLAIR/full_html/by_service.html#strictness/service/first_file&strictness{"select":true,"selection":{"hiddenAreaKinds":[],"hiddenSubareaKinds":[],"show":true,"selector":{"enabled":true,"negated":false,"kind":2,"children":[{"enabled":true,"negated":false,"kind":0,"domain":"kind","inputs":[{"enabled":true,"text":"violation"}]}]}}}'>Report by issue strictness (Mandatory/Required/Advisory) (violations)</a>
<li><a href='ECLAIR/full_html/by_service.html#strictness/service/first_file&strictness'>Report by issue strictness (Mandatory/Required/Advisory) (all)</a>
</ul>

<ul>
<li><a href="ECLAIR/full_html/index.html">Default ECLAIR report</a>
<li><a href="ECLAIR/full_txt/">Default ECLAIR report (plain text)</a>
</ul>

<span style="font-size: 75%">
<p>
ECLAIR terminology cheatsheet:
</p>
<ul>
<li>"violation" is formally proven issue
<li>"caution" is <i>not</i> formally proven issue, may be a false positive
<li>"information" is <i>not an issue</i> (from MISRA rules PoV), just FYI aka "know your codebase better"
</ul>
</span>

</body>
</html>
EOF
