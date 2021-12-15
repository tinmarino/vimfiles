[MASTER]

disable=invalid-name,
        multiple-statements,
        too-many-instance-attributes,
        too-few-public-methods,

        import-error,
        bare-except,
        too-many-ancestors,

        # except Exception as e:
        broad-except,

        redefined-outer-name,
        useless-return,
        misplaced-comparison-constant,

        # When there is a TODO
        fixme,

        non-ascii-name
        
#indent-string='  '
#        missing-function-docstring,
#        missing-module-docstring,
#        wrong-import-position,
#        import-outside-toplevel,

max-line-length=120
