# ------------------------------------------------------------------------------
#  Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
# ------------------------------------------------------------------------------
#  Author:
#    fdk-support@arista.com
#
#  Description:
#    Licensed under BSD 3-clause license:
#      https://opensource.org/licenses/BSD-3-Clause
#
#  Tags:
#    license-bsd-3-clause
#
# ------------------------------------------------------------------------------

# Decorator to format the docstring before passing the function to another decorator
def format_docstring(*p, **k):
    def format_docstring_deco(func):
        func.__doc__ = func.__doc__.format(*p, **k)
        return func

    return format_docstring_deco
