from pygments.token import Token

# See other output
c = get_config()
c.ZMQTerminalInteractiveShell.include_other_output = True

c.ZMQTerminalInteractiveShell.highlighting_style = "fruity"

c.ZMQTerminalInteractiveShell.highlighting_style_overrides = {
    Token.Prompt: '#2aa198',  # cyan
    Token.PromptNum: '#268bd2 bold',  #blue
    Token.OutPrompt: '#b58900',  # yellow
    Token.RemotePrompt: '#d33682',  # magenta
    # Token.Name.Function: '#2aa198',  #blue
    # Token.Name.Class: '#2aa198',  #blue
    # Token.Name.Namespace: '#2aa198',  #blue
}

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
