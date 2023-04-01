#Configurationfileforipython.

#------------------------------------------------------------------------------
#InteractiveShellApp(Configurable)configuration
#------------------------------------------------------------------------------

##AMixinforapplicationsthatstartInteractiveShellinstances.
#
#Providesconfigurablesforloadingextensionsandexecutingfilesaspartof
#configuringaShellenvironment.
#
#Thefollowingmethodsshouldbecalledbythe:meth:`initialize`methodofthe
#subclass:
#
#-:meth:`init_path`
#-:meth:`init_shell`(tobeimplementedbythesubclass)
#-:meth:`init_gui_pylab`
#-:meth:`init_extensions`
#-:meth:`init_code`

##Executethegivencommandstring.
#c.InteractiveShellApp.code_to_run=''

##RunthefilereferencedbythePYTHONSTARTUPenvironmentvariableatIPython
#startup.
#c.InteractiveShellApp.exec_PYTHONSTARTUP=True

##ListoffilestorunatIPythonstartup.
#c.InteractiveShellApp.exec_files=[]

##linesofcodetorunatIPythonstartup.
#c.InteractiveShellApp.exec_lines=[]

##AlistofdottedmodulenamesofIPythonextensionstoload.
#c.InteractiveShellApp.extensions=[]

##dottedmodulenameofanIPythonextensiontoload.
#c.InteractiveShellApp.extra_extension=''

##Afiletoberun
#c.InteractiveShellApp.file_to_run=''

##EnableGUIeventloopintegrationwithanyof('asyncio','glut','gtk',
#'gtk2','gtk3','osx','pyglet','qt','qt4','qt5','tk','wx','gtk2',
#'qt4').
#c.InteractiveShellApp.gui=None

##Shouldvariablesloadedatstartup(bystartupfiles,exec_lines,etc.)be
#hiddenfromtoolslike%who?
#c.InteractiveShellApp.hide_initial_ns=True

##Configurematplotlibforinteractiveusewiththedefaultmatplotlibbackend.
#c.InteractiveShellApp.matplotlib=None

##Runthemoduleasascript.
#c.InteractiveShellApp.module_to_run=''

##Pre-loadmatplotlibandnumpyforinteractiveuse,selectingaparticular
#matplotlibbackendandloopintegration.
#c.InteractiveShellApp.pylab=None

##Iftrue,IPythonwillpopulatetheusernamespacewithnumpy,pylab,etc.and
#an``import*``isdonefromnumpyandpylab,whenusingpylabmode.
#
#WhenFalse,pylabmodeshouldnotimportanynamesintotheusernamespace.
#c.InteractiveShellApp.pylab_import_all=True

##ReraiseexceptionsencounteredloadingIPythonextensions?
#c.InteractiveShellApp.reraise_ipython_extension_failures=False

#------------------------------------------------------------------------------
#Application(SingletonConfigurable)configuration
#------------------------------------------------------------------------------

##Thisisanapplication.

##Thedateformatusedbyloggingformattersfor%(asctime)s
#c.Application.log_datefmt='%Y-%m-%d%H:%M:%S'

##TheLoggingformattemplate
#c.Application.log_format='[%(name)s]%(highlevel)s%(message)s'

##Settheloglevelbyvalueorname.
#c.Application.log_level=30

#------------------------------------------------------------------------------
#BaseIPythonApplication(Application)configuration
#------------------------------------------------------------------------------

##IPython:anenhancedinteractivePythonshell.

##Whethertocreateprofiledirifitdoesn'texist
#c.BaseIPythonApplication.auto_create=False

##Whethertoinstallthedefaultconfigfilesintotheprofiledir.Ifanew
#profileisbeingcreated,andIPythoncontainsconfigfilesforthatprofile,
#thentheywillbestagedintothenewdirectory.Otherwise,defaultconfig
#fileswillbeautomaticallygenerated.
#c.BaseIPythonApplication.copy_config_files=False

##Pathtoanextraconfigfiletoload.
#
#Ifspecified,loadthisconfigfileinadditiontoanyotherIPythonconfig.
#c.BaseIPythonApplication.extra_config_file=''

##ThenameoftheIPythondirectory.Thisdirectoryisusedforlogging
#configuration(throughprofiles),historystorage,etc.Thedefaultisusually
#$HOME/.ipython.Thisoptioncanalsobespecifiedthroughtheenvironment
#variableIPYTHONDIR.
#c.BaseIPythonApplication.ipython_dir=''

##Whethertooverwriteexistingconfigfileswhencopying
#c.BaseIPythonApplication.overwrite=False

##TheIPythonprofiletouse.
#c.BaseIPythonApplication.profile='default'

##CreateamassivecrashreportwhenIPythonencounterswhatmaybeaninternal
#error.Thedefaultistoappendashortmessagetotheusualtraceback
#c.BaseIPythonApplication.verbose_crash=False

#------------------------------------------------------------------------------
#TerminalIPythonApp(BaseIPythonApplication,InteractiveShellApp)configuration
#------------------------------------------------------------------------------

##WhethertodisplayabanneruponstartingIPython.
#c.TerminalIPythonApp.display_banner=True

##Ifacommandorfileisgivenviathecommand-line,e.g.'ipythonfoo.py',
#startaninteractiveshellafterexecutingthefileorcommand.
#c.TerminalIPythonApp.force_interact=False

##ClasstousetoinstantiatetheTerminalInteractiveShellobject.Usefulfor
#customFrontends
#c.TerminalIPythonApp.interactive_shell_class=\
#'IPython.terminal.interactiveshell.TerminalInteractiveShell'

##StartIPythonquicklybyskippingtheloadingofconfigfiles.
#c.TerminalIPythonApp.quick=False

#------------------------------------------------------------------------------
#InteractiveShell(SingletonConfigurable)configuration
#------------------------------------------------------------------------------

##Anenhanced,interactiveshellforPython.

##'all','last','last_expr'or'none','last_expr_or_assign'specifyingwhich
#nodesshouldberuninteractively(displayingoutputfromexpressions).
#c.InteractiveShell.ast_node_interactivity='last_expr'

##Alistofast.NodeTransformersubclassinstances,whichwillbeappliedto
#userinputbeforecodeisrun.
#c.InteractiveShell.ast_transformers=[]

##Automaticallyrunawaitstatementinthetoplevelrepl.
#c.InteractiveShell.autoawait=True

##MakeIPythonautomaticallycallanycallableobjectevenifyoudidn'ttype
#explicitparentheses.Forexample,'str43'becomes'str(43)'automatically.
#Thevaluecanbe'0'todisablethefeature,'1'for'smart'autocall,where
#itisnotappliediftherearenomoreargumentsontheline,and'2'for
#'full'autocall,whereallcallableobjectsareautomaticallycalled(evenif
#noargumentsarepresent).
#c.InteractiveShell.autocall=0

##AutoindentIPythoncodeenteredinteractively.
#c.InteractiveShell.autoindent=True

##Enablemagiccommandstobecalledwithouttheleading%.
#c.InteractiveShell.automagic=True

##Thepartofthebannertobeprintedbeforetheprofile

##Thepartofthebannertobeprintedaftertheprofile
#c.InteractiveShell.banner2=''

##Setthesizeoftheoutputcache.Thedefaultis1000,youcanchangeit
#permanentlyinyourconfigfile.Settingitto0completelydisablesthe
#cachingsystem,andtheminimumvalueacceptedis3(ifyouprovideavalue
#lessthan3,itisresetto0andawarningisissued).Thislimitisdefined
#becauseotherwiseyou'llspendmoretimere-flushingatoosmallcachethan
#working
#c.InteractiveShell.cache_size=1000

##Usecolorsfordisplayinginformationaboutobjects.Becausethisinformation
#ispassedthroughapager(like'less'),andsomepagersgetconfusedwith
#colorcodes,thiscapabilitycanbeturnedoff.
#c.InteractiveShell.color_info=True

##Setthecolorscheme(NoColor,Neutral,Linux,orLightBG).
#c.InteractiveShell.colors='Neutral'

##
#c.InteractiveShell.debug=False

##Don'tcallpost-executefunctionsthathavefailedinthepast.
#c.InteractiveShell.disable_failing_post_execute=False

##IfTrue,anythingthatwouldbepassedtothepagerwillbedisplayedas
#regularoutputinstead.
#c.InteractiveShell.display_page=False

##(ProvisionalAPI)enableshtmlrepresentationinmimebundlessenttopagers.
#c.InteractiveShell.enable_html_pager=False

##Totallengthofcommandhistory
#c.InteractiveShell.history_length=10000

##Thenumberofsavedhistoryentriestobeloadedintothehistorybufferat
#startup.
#c.InteractiveShell.history_load_length=1000

##
#c.InteractiveShell.ipython_dir=''

##Startloggingtothegivenfileinappendmode.Use`logfile`tospecifyalog
#fileto**overwrite**logsto.
#c.InteractiveShell.logappend=''

##Thenameofthelogfiletouse.
#c.InteractiveShell.logfile=''

##Startloggingtothedefaultlogfileinoverwritemode.Use`logappend`to
#specifyalogfileto**append**logsto.
#c.InteractiveShell.logstart=False

##Selectthelooprunnerthatwillbeusedtoexecutetop-levelasynchronous
#code
#c.InteractiveShell.loop_runner='IPython.core.interactiveshell._asyncio_runner'

##
#c.InteractiveShell.object_info_string_level=0

##Automaticallycallthepdbdebuggeraftereveryexception.
#c.InteractiveShell.pdb=False

##DeprecatedsinceIPython4.0andignoredsince5.0,set
#TerminalInteractiveShell.promptsobjectdirectly.
#c.InteractiveShell.prompt_in1='In[\\#]:'

##DeprecatedsinceIPython4.0andignoredsince5.0,set
#TerminalInteractiveShell.promptsobjectdirectly.
#c.InteractiveShell.prompt_in2='.\\D.:'

##DeprecatedsinceIPython4.0andignoredsince5.0,set
#TerminalInteractiveShell.promptsobjectdirectly.
#c.InteractiveShell.prompt_out='Out[\\#]:'

##DeprecatedsinceIPython4.0andignoredsince5.0,set
#TerminalInteractiveShell.promptsobjectdirectly.
#c.InteractiveShell.prompts_pad_left=True

##
#c.InteractiveShell.quiet=False

##
#c.InteractiveShell.separate_in='\n'

##
#c.InteractiveShell.separate_out=''

##
#c.InteractiveShell.separate_out2=''

##Showrewritteninput,e.g.forautocall.
#c.InteractiveShell.show_rewritten_input=True

##Enablesrichhtmlrepresentationofdocstrings.(Thisrequiresthedocrepr
#module).
#c.InteractiveShell.sphinxify_docstring=False

##
#c.InteractiveShell.wildcards_case_sensitive=True

##SwitchmodesfortheIPythonexceptionhandlers.
#c.InteractiveShell.xmode='Context'

#------------------------------------------------------------------------------
#TerminalInteractiveShell(InteractiveShell)configuration
#------------------------------------------------------------------------------

##AutoformattertoreformatTerminalcode.Canbe`'black'`or`None`
#c.TerminalInteractiveShell.autoformatter=None

##SettoconfirmwhenyoutrytoexitIPythonwithanEOF(Control-DinUnix,
#Control-Z/EnterinWindows).Bytyping'exit'or'quit',youcanforcea
#directexitwithoutanyconfirmation.
#c.TerminalInteractiveShell.confirm_exit=True

##Optionsfordisplayingtabcompletions,'column','multicolumn',and
#'readlinelike'.Theseoptionsarefor`prompt_toolkit`,see`prompt_toolkit`
#documentationformoreinformation.
#c.TerminalInteractiveShell.display_completions='multicolumn'

##Shortcutstyletouseattheprompt.'vi'or'emacs'.
#c.TerminalInteractiveShell.editing_mode='emacs'

##SettheeditorusedbyIPython(defaultto$EDITOR/vi/notepad).
#c.TerminalInteractiveShell.editor='vi'

##Allowstoenable/disabletheprompttoolkithistorysearch
#c.TerminalInteractiveShell.enable_history_search=True

##Enablevi(v)orEmacs(C-XC-E)shortcutstoopenanexternaleditor.Thisis
#inadditiontotheF2binding,whichisalwaysenabled.
#c.TerminalInteractiveShell.extra_open_editor_shortcuts=False

##ProvideanalternativehandlertobecalledwhentheuserpressesReturn.This
#isanadvancedoptionintendedfordebugging,whichmaybechangedorremoved
#inlaterreleases.
#c.TerminalInteractiveShell.handle_return=None

##Highlightmatchingbrackets.
#c.TerminalInteractiveShell.highlight_matching_brackets=True

##ThenameorclassofaPygmentsstyletouseforsyntaxhighlighting.Tosee
#availablestyles,run`pygmentize-Lstyles`.
#c.TerminalInteractiveShell.highlighting_style=traitlets.Undefined

##Overridehighlightingformatforspecifictokens
#c.TerminalInteractiveShell.highlighting_style_overrides={}

##
#c.TerminalInteractiveShell.mime_renderers={}

##Enablemousesupportintheprompt(Note:preventsselectingtextwiththe
#mouse)
#c.TerminalInteractiveShell.mouse_support=False

##Displaythecurrentvimode(whenusingvieditingmode).
#c.TerminalInteractiveShell.prompt_includes_vi_mode=True

##ClassusedtogeneratePrompttokenforprompt_toolkit
#c.TerminalInteractiveShell.prompts_class='IPython.terminal.prompts.Prompts'

##Use`raw_input`fortheREPL,withoutcompletionandpromptcolors.
#
#UsefulwhencontrollingIPythonasasubprocess,andpipingSTDIN/OUT/ERR.
#Knownusageare:IPythonowntestingmachinery,andemacsinferior-shell
#integrationthroughelpy.
#
#Thismodedefaultto`True`ifthe`IPY_TEST_SIMPLE_PROMPT`environment
#variableisset,orthecurrentterminalisnotatty.
#c.TerminalInteractiveShell.simple_prompt=False

##Numberoflineatthebottomofthescreentoreserveforthecompletionmenu
#c.TerminalInteractiveShell.space_for_menu=6

##Automaticallysettheterminaltitle
#c.TerminalInteractiveShell.term_title=True

##Customizetheterminaltitleformat.Thisisapythonformatstring.
#Availablesubstitutionsare:{cwd}.
#c.TerminalInteractiveShell.term_title_format='IPython:{cwd}'

##Use24bitcolorsinsteadof256colorsinprompthighlighting.Ifyour
#terminalsupportstruecolor,thefollowingcommandshouldprint'TRUECOLOR'
#inorange:printf"\x1b[38;2;255;100;0mTRUECOLOR\x1b[0m\n"
#c.TerminalInteractiveShell.true_color=False

#------------------------------------------------------------------------------
#HistoryAccessor(HistoryAccessorBase)configuration
#------------------------------------------------------------------------------

##Accessthehistorydatabasewithoutaddingtoit.
#
#Thisisintendedforusebystandalonehistorytools.IPythonshellsuse
#HistoryManager,below,whichisasubclassofthis.

##OptionsforconfiguringtheSQLiteconnection
#
#Theseoptionsarepassedaskeywordargstosqlite3.connectwhenestablishing
#databaseconnections.
#c.HistoryAccessor.connection_options={}

##enabletheSQLitehistory
#
#setenabled=FalsetodisabletheSQLitehistory,inwhichcasetherewillbe
#nostoredhistory,noSQLiteconnection,andnobackgroundsavingthread.
#ThismaybenecessaryinsomethreadedenvironmentswhereIPythonisembedded.
#c.HistoryAccessor.enabled=True

##PathtofiletouseforSQLitehistorydatabase.
#
#Bydefault,IPythonwillputthehistorydatabaseintheIPythonprofile
#directory.Ifyouwouldrathershareonehistoryamongprofiles,youcanset
#thisvalueineach,sothattheyareconsistent.
#
#Duetoanissuewithfcntl,SQLiteisknowntomisbehaveonsomeNFSmounts.
#IfyouseeIPythonhanging,trysettingthistosomethingonalocaldisk,
#e.g::
#
#ipython--HistoryManager.hist_file=/tmp/ipython_hist.sqlite
#
#youcanalsousethespecificvalue`:memory:`(includingthecolonatboth
#endbutnotthebackticks),toavoidcreatinganhistoryfile.
#c.HistoryAccessor.hist_file=''

#------------------------------------------------------------------------------
#HistoryManager(HistoryAccessor)configuration
#------------------------------------------------------------------------------

##Aclasstoorganizeallhistory-relatedfunctionalityinoneplace.

##Writetodatabaseeveryxcommands(highervaluessavediskaccess&power).
#Valuesof1orlesseffectivelydisablecaching.
#c.HistoryManager.db_cache_size=0

##Shouldthehistorydatabaseincludeoutput?(default:no)
#c.HistoryManager.db_log_output=False

#------------------------------------------------------------------------------
#ProfileDir(LoggingConfigurable)configuration
#------------------------------------------------------------------------------

##Anobjecttomanagetheprofiledirectoryanditsresources.
#
#TheprofiledirectoryisusedbyallIPythonapplications,tomanage
#configuration,loggingandsecurity.
#
#Thisobjectknowshowtofind,createandmanagethesedirectories.This
#shouldbeusedbyanycodethatwantstohandleprofiles.

##Settheprofilelocationdirectly.Thisoverridesthelogicusedbythe
#`profile`option.
#c.ProfileDir.location=''

#------------------------------------------------------------------------------
#BaseFormatter(Configurable)configuration
#------------------------------------------------------------------------------

##Abaseformatterclassthatisconfigurable.
#
#Thisformattershouldusuallybeusedasthebaseclassofallformatters.It
#isatraited:class:`Configurable`classandincludesanextensibleAPIfor
#userstodeterminehowtheirobjectsareformatted.Thefollowinglogicis
#usedtofindafunctiontoformatangivenobject.
#
#1.Theobjectisintrospectedtoseeifithasamethodwiththename
#:attr:`print_method`.Ifisdoes,thatobjectispassedtothatmethod
#forformatting.
#2.Ifnoprintmethodisfound,threeinternaldictionariesareconsulted
#tofindprintmethod::attr:`singleton_printers`,:attr:`type_printers`
#and:attr:`deferred_printers`.
#
#Usersshouldusethesedictionariestoregisterfunctionsthatwillbeusedto
#computetheformatdatafortheirobjects(ifthoseobjectsdon'thavethe
#specialprintmethods).Theeasiestwayofusingthesedictionariesisthrough
#the:meth:`for_type`and:meth:`for_type_by_name`methods.
#
#Ifnofunction/callableisfoundtocomputetheformatdata,``None``is
#returnedandthisformattypeisnotused.

##
#c.BaseFormatter.deferred_printers={}

##
#c.BaseFormatter.enabled=True

##
#c.BaseFormatter.singleton_printers={}

##
#c.BaseFormatter.type_printers={}

#------------------------------------------------------------------------------
#PlainTextFormatter(BaseFormatter)configuration
#------------------------------------------------------------------------------

##Thedefaultpretty-printer.
#
#Thisuses:mod:`IPython.lib.pretty`tocomputetheformatdataoftheobject.
#Iftheobjectcannotbeprettyprinted,:func:`repr`isused.Seethe
#documentationof:mod:`IPython.lib.pretty`fordetailsonhowtowritepretty
#printers.Hereisasimpleexample::
#
#defdtype_pprinter(obj,p,cycle):
#ifcycle:
#returnp.text('dtype(...)')
#ifhasattr(obj,'fields'):
#ifobj.fieldsisNone:
#p.text(repr(obj))
#else:
#p.begin_group(7,'dtype([')
#fori,fieldinenumerate(obj.descr):
#ifi>0:
#p.text(',')
#p.breakable()
#p.pretty(field)
#p.end_group(7,'])')

##
#c.PlainTextFormatter.float_precision=''

##Truncatelargecollections(lists,dicts,tuples,sets)tothissize.
#
#Setto0todisabletruncation.
#c.PlainTextFormatter.max_seq_length=1000

##
#c.PlainTextFormatter.max_width=79

##
#c.PlainTextFormatter.newline='\n'

##
#c.PlainTextFormatter.pprint=True

##
#c.PlainTextFormatter.verbose=False

#------------------------------------------------------------------------------
#Completer(Configurable)configuration
#------------------------------------------------------------------------------

##Enableunicodecompletions,e.g.\alpha<tab>.Includescompletionoflatex
#commands,unicodenames,andexpandingunicodecharactersbacktolatex
#commands.
#c.Completer.backslash_combining_completions=True

##EnabledebugfortheCompleter.Mostlyprintextrainformationfor
#experimentaljediintegration.
#c.Completer.debug=False

##ActivategreedycompletionPENDINGDEPRECTION.thisisnowmostlytakencare
#ofwithJedi.
#
#Thiswillenablecompletiononelementsoflists,resultsoffunctioncalls,
#etc.,butcanbeunsafebecausethecodeisactuallyevaluatedonTAB.
#c.Completer.greedy=False

##Experimental:restricttime(inmilliseconds)duringwhichJedicancompute
#types.Setto0tostopcomputingtypes.Non-zerovaluelowerthan100msmay
#hurtperformancebypreventingjeditobuilditscache.
#c.Completer.jedi_compute_type_timeout=400

##Experimental:UseJeditogenerateautocompletions.DefaulttoTrueifjediis
#installed.
#c.Completer.use_jedi=True

#------------------------------------------------------------------------------
#IPCompleter(Completer)configuration
#------------------------------------------------------------------------------

##ExtensionofthecompleterclasswithIPython-specificfeatures

##DEPRECATEDasofversion5.0.
#
#Instructthecompletertouse__all__forthecompletion
#
#Specifically,whencompletingon``object.<tab>``.
#
#WhenTrue:onlythosenamesinobj.__all__willbeincluded.
#
#WhenFalse[default]:the__all__attributeisignored
#c.IPCompleter.limit_to__all__=False

##Whethertomergecompletionresultsintoasinglelist
#
#IfFalse,onlythecompletionresultsfromthefirstnon-emptycompleterwill
#bereturned.
#c.IPCompleter.merge_completions=True

##Instructthecompletertoomitprivatemethodnames
#
#Specifically,whencompletingon``object.<tab>``.
#
#When2[default]:allnamesthatstartwith'_'willbeexcluded.
#
#When1:all'magic'names(``__foo__``)willbeexcluded.
#
#When0:nothingwillbeexcluded.
#c.IPCompleter.omit__names=2

#------------------------------------------------------------------------------
#ScriptMagics(Magics)configuration
#------------------------------------------------------------------------------

##Magicsfortalkingtoscripts
#
#Thisdefinesabase`%%script`cellmagicforrunningacellwithaprogramin
#asubprocess,andregistersafewtop-levelmagicsthatcall%%scriptwith
#commoninterpreters.

##Extrascriptcellmagicstodefine
#
#Thisgeneratessimplewrappersof`%%scriptfoo`as`%%foo`.
#
#Ifyouwanttoaddscriptmagicsthataren'tonyourpath,specifythemin
#script_paths
#c.ScriptMagics.script_magics=[]

##Dictmappingshort'ruby'namestofullpaths,suchas'/opt/secret/bin/ruby'
#
#Onlynecessaryforitemsinscript_magicswherethedefaultpathwillnotfind
#therightinterpreter.
#c.ScriptMagics.script_paths={}

#------------------------------------------------------------------------------
#LoggingMagics(Magics)configuration
#------------------------------------------------------------------------------

##Magicsrelatedtoallloggingmachinery.

##Suppressoutputoflogstatewhenloggingisenabled
#c.LoggingMagics.quiet=False

#------------------------------------------------------------------------------
#StoreMagics(Magics)configuration
#------------------------------------------------------------------------------

##Lightweightpersistenceforpythonvariables.
#
#Providesthe%storemagic.

##IfTrue,any%store-dvariableswillbeautomaticallyrestoredwhenIPython
#starts.
#c.StoreMagics.autorestore=False
