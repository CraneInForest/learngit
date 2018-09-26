--
-- Copyright (C) GoodTeamStudio, All rights reserved!
--
-- Author: Zaxbbun.Du
--

--
-- @brief 游戏lua层进入点
--

xpcall = function (func, err, ...)
    local unpack = table.unpack or unpack

    local function impl(...)
        local args = { ... }

        if args[1] == true then
            return unpack(args)
        end

        table.remove(args, 1)
        err(unpack(args))

        return false
    end

    return impl(pcall(func, ...))
end

-- setmetatable(_G, { __newindex = function (_, k, v)
--     error(string.format('attempt to use global variable `%s = %s`', k, v))
-- end})

local oops  = require 'core.oops'
local LOG   = require 'core.log'
local VAR   = require 'util.var'
local LANG  = require 'util.lang'
local NET   = require 'wrap.network'
local REG   = require 'wrap.registry'
local jpush = require 'jpush.init'
local test  = require 'test.init'
local guide  = require 'guide.guide'
local config  = require 'etc.config'

local function main(...)
    local data_path, log_path, var_path = ...
    REG.dataPath = data_path
    REG.varPath = var_path

    LOG.init('duck', log_path, 'debug')
    VAR.init(string.format('%s/%s', var_path, 'duck.local.lua'))

    --如果为空存档，则进行初始化
    if (nil == VAR.settingMusic) then
        VAR.settingMusic = true
        VAR.settingSound = true
        VAR.settingNotifyAttack = true
        VAR.settingNotifyGeneral = true
        VAR.loginTimes = 0
        VAR()
    end

    REG.magicell.TTSoundManager.setBgMusicIsOn(VAR.settingMusic)
    REG.magicell.TTSoundManager.setSoundEffectIsOn(VAR.settingSound)
    REG.magicell.TTSoundManager.PlayBgMusic('audios/BGM')

    
    require 'ui.cloud'.Init()

    LOG.debug('init language ...')
    LANG.init(VAR.lang)

    LOG.debug('init network ...')
    NET.init()
    
    LOG.debug('init jpush ...')   
    local JPush = REG.magicell.TaggedGameObjects.FindGameObjectWithTag('JPush')
    REG.JPush = JPush:GetComponent(typeof(REG.JPush.JPushBehaviour))
    REG.JPush:Initiate(jpush) 

    LOG.debug('inti transition ...')
    require 'ui.transition'.Init()

    LOG.debug('init ads')
    require 'ads.init'()

    require 'ui.retry'()

    LOG.debug('testing ...')
    test()
    --初始化
    require 'ui.sceneManager'.Init()

    --新手引导
    if (config.newguide == 1) then
        guide.init()
        --require 'guide.guideTest'.Init()
    end

    LOG.debug('init notice')
    require 'ui.notice'.Init()
    

    coroutine.start(function()
        collectgarbage('collect')
        coroutine.wait(60)
    end)
end

log.debug('1')
log.debug('3')
xpcall(main, oops, ...)
