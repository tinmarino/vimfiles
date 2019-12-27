
# See other output
c = get_config()
c.ZMQTerminalInteractiveShell.include_other_output  = True

# History
# c.ZMQTerminalInteractiveShell.history_load_length = 10000
# c.Session.digest_history_size = 100000

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
