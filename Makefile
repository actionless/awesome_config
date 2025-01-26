.PHONY: lint luacheck shellcheck

lint: luacheck shellcheck

luacheck:
	# Running luacheck:
	luacheck .
	# :: luacheck passed ::

shellcheck:
	# Running shellcheck:
	find . \
		\( \
			-name '*.sh' \
			-not -wholename '*/*.*build/*' \
		\) \
		-exec sh -c 'set -x ; shellcheck "$$@"' shellcheck {} \+
	# :: shellcheck passed ::
