
# See other output
c = get_config()
c.ZMQTerminalInteractiveShell.include_other_output  = True

# Exit leaves kernel alone
# seems I'll do that in ipython kernel

# Does not work any more
# from ipykernel.zmqshell import ZMQInteractiveShell
# from IPython.core.autocall import ZMQExitAutocall
#
#
# class KeepAlive(ZMQExitAutocall):
#     def __call__(self):
#         super().__call__(True)
#
# ZMQInteractiveShell.exiter = KeepAlive()
