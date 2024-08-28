module PokemonDebugMixin
  def pbPokemonDebug(pkmn, pkmnid, heldpoke = nil, settingUpBattle = false)
		commands = CommandMenuList.new
    MenuHandlers.each_available(:pokemon_debug_menu) do |option, hash, name|
      next if !hash["always_show"].nil? && !hash["always_show"]
      if hash["description"].is_a?(Proc)
        description = hash["description"].call
      elsif !hash["description"].nil?
        description = _INTL(hash["description"])
      end
      commands.add(option, hash, name, description)
    end
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    sprites = {}
    sprites["textbox"] = pbCreateMessageWindow
    sprites["textbox"].letterbyletter = false
		sprites["cmdwindow"] = Window_CommandPokemonEx.new(commands.list)
    cmdwindow = sprites["cmdwindow"]
    cmdwindow.x        = 0
    cmdwindow.y        = 0
    cmdwindow.width    = Graphics.width / 2
    cmdwindow.height   = Graphics.height - sprites["textbox"].height
    cmdwindow.viewport = viewport
    cmdwindow.visible  = true
    sprites["textbox"].text = commands.getDesc(cmdwindow.index)
    # Main loop
    ret = -1
    refresh = true
    loop do
      loop do
        oldindex = cmdwindow.index
        cmdwindow.update
        if refresh || cmdwindow.index != oldindex
          sprites["textbox"].text = commands.getDesc(cmdwindow.index)
          refresh = false
        end
        Graphics.update
        Input.update
        if Input.trigger?(Input::BACK)
          parent = commands.getParent
          if parent
            pbPlayCancelSE
            commands.currentList = parent[0]
            cmdwindow.commands = commands.list
            cmdwindow.index = parent[1]
            refresh = true
          else
            ret = -1
            break
          end
        elsif Input.trigger?(Input::USE)
          ret = cmdwindow.index
          break
        end
      end
      break if ret < 0
      cmd = commands.getCommand(ret)
      if commands.hasSubMenu?(cmd)
        pbPlayDecisionSE
        commands.currentList = cmd
        cmdwindow.commands = commands.list
        cmdwindow.index = 0
        refresh = true
      else
        sprites["cmdwindow"].visible = false
        sprites["textbox"].visible = false
        MenuHandlers.call(:pokemon_debug_menu, cmd, "effect", pkmn, pkmnid, heldpoke, settingUpBattle, self)
        sprites["cmdwindow"].visible = true
        sprites["textbox"].visible = true
      end
    end
    pbPlayCloseMenuSE
    pbDisposeMessageWindow(sprites["textbox"])
    pbDisposeSpriteHash(sprites)
    viewport.dispose
  end
end
