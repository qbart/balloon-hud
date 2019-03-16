require "love"
require "gooi"

Player = {
    counter = 0,
    currentTime = 0,
    totalTime = 0
}

COUNTER_OFF = 0
COUNTER_ON = 1
COUNTER_PAUSED = 2

CounterState = {
    status = COUNTER_OFF,
    player = nil
}

function Player:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Player:reset()
    self.counter = 0
    self.currentTime = 0
    self.totalTime = 0
end

function Player:inc()
    self.counter = self.counter + 1
end

function Player:resetCurretTime()
    self.currentTime = 0
end

function Player:addTime(dt)
    self.currentTime = self.currentTime + dt
    self.totalTime = self.totalTime + dt
end

function formatTime(s)
    local seconds = math.floor(s) % 60
    local minutes = math.floor(math.floor(s) / 60)

    return string.format("%d:%02d", minutes, seconds)
end

function switchPlayer(player)
    if player == Players.Red then
        CounterState.player = Players.Red
        timer1:fg(colors["green"])
        timer2:fg(colors["white"])
        CounterState.player:inc()
        CounterState.player:resetCurretTime()
    elseif player == Players.Blue then
        CounterState.player = Players.Blue
        timer2:fg(colors["green"])
        timer1:fg(colors["white"])
        CounterState.player:inc()
        CounterState.player:resetCurretTime()
    end
end

function love.load()
    G = love.graphics
    Players = {}
    Players.Red = Player:new()
    Players.Blue = Player:new()

    love.window.setMode(800, 480, {
        borderless = true,
        centered = true
    })
    G.setBackgroundColor(0.15, 0.15, 0.15)

    styles = {
        small = {
            font = G.newFont(26),
            showBorder = true
        },
        big = {
            font = G.newFont(144),
            showBorder = true
        }
    }
    colors = {
        blue = "#29aae2",
        red = "#e84a99",
        green = "#7fe84a",
        white = "#ffffff",
        bg = "#747d47"
    }

    gooi.desktopMode()
    gooi.shadow()

    toolbar = gooi.newPanel({x = 0, y = 0, w = 800, h = 80, layout = "game"})


    btnReset = gooi.newButton({
        text = "Reset",
        x = 0,
        y = 0,
        w = 100,
        h = 40
    }):danger()
    btnQuit = gooi.newButton({
        text = "Quit",
        x = 0,
        y = 0,
        w = 80,
        h = 40
    }):danger()
    btnSubmit = gooi.newButton({
        text = "Start",
        x = 0,
        y = 0,
        w = 100,
        h = 40
    }):success()

    toolbar:add(btnQuit, "t-l")
    toolbar:add(btnReset, "t-l")
    toolbar:add(btnSubmit, "t-r")

    grid = gooi.newPanel({x = 0, y = 80, w = 800, h = 400, layout = "grid 8x2"})
    grid:setRowspan(1, 1, 4):setRowspan(1, 2, 4)

    gooi.setStyle(styles["big"])
    counter1 = gooi.newButton({text = "0"}):center():bg({0.15, 0.15, 0.15}):fg(colors["red"])
    counter2 = gooi.newButton({text = "0"}):center():bg({0.15, 0.15, 0.15}):fg(colors["blue"])
    gooi.setStyle(styles["small"])
    timer1 = gooi.newLabel({text = "0:00"}):center():fg(colors["white"])
    timer2 = gooi.newLabel({text = "0:00"}):center():fg(colors["white"])
    total1 = gooi.newLabel({text = "0:00"}):center():fg(colors["red"])
    total2 = gooi.newLabel({text = "0:00"}):center():fg(colors["blue"])

    grid:add(counter1)
    grid:add(counter2)
    grid:add(timer1, "6,1")
    grid:add(timer2, "6,2")
    grid:add(total1, "7,1")
    grid:add(total2, "7,2")

    btnQuit:onRelease(
        function()
            gooi.confirm({
                text = "Sure?",
                ok = function()
                    quit()
                end
            })
        end
    )
    btnReset:onRelease(
        function()
            gooi.confirm({
                text = "Sure?",
                ok = function()
                    CounterState.status = COUNTER_OFF
                    btnSubmit:setText("Start")
                    btnSubmit:success()
                    CounterState.player = nil
                    Players.Red:reset()
                    Players.Blue:reset()
                    timer1:fg(colors["white"])
                    timer2:fg(colors["white"])
                end
            })
        end
    )
    btnSubmit:onRelease(
        function()
            if CounterState.status == COUNTER_ON then
                CounterState.status = COUNTER_PAUSED
                btnSubmit:setText("Resume")
                btnSubmit:warning()
            elseif CounterState.status == COUNTER_PAUSED then
                CounterState.status = COUNTER_ON
                btnSubmit:setText("Pause")
                btnSubmit:warning()
            elseif CounterState.status == COUNTER_OFF then
                btnSubmit:setText("Pause")
                btnSubmit:warning()
                gooi.confirm({
                    text = "Who starts?",
                    cancel = function()
                        CounterState.status = COUNTER_ON
                        switchPlayer(Players.Red)
                        CounterState.player:reset()
                        CounterState.player:inc()
                    end,
                    ok = function()
                        CounterState.status = COUNTER_ON
                        switchPlayer(Players.Blue)
                        CounterState.player:reset()
                        CounterState.player:inc()
                    end,
                    cancelText = "red",
                    okText = "blue"
                })
            end
        end
    )
    counter1:onRelease(
        function()
            if CounterState.status == COUNTER_ON then
                if CounterState.player == Players.Red then
                    switchPlayer(Players.Blue)
                end
            end
        end
    )
    counter2:onRelease(
        function()
            if CounterState.status == COUNTER_ON then
                if CounterState.player == Players.Blue then
                    switchPlayer(Players.Red)
                end
            end
        end
    )
end

function love.update(dt)
    gooi.update(dt)

    if CounterState.status == COUNTER_ON then
        CounterState.player:addTime(dt)
    end

    -- if math.floor(timerSwitch) >= 5 then
    --     timerSwitch = 0
    --     if Players.Active == Players.Red then
    --         switchPlayer(Players.Blue)
    --         Players.Blue:inc()
    --     else
    --         switchPlayer(Players.Red)
    --         Players.Red:inc()
    --     end
    -- end

    -- update RED labels
    timer1:setText(formatTime(Players.Red.currentTime))
    total1:setText(formatTime(Players.Red.totalTime))
    counter1:setText(Players.Red.counter)

    -- updatge BLUE labels
    timer2:setText(formatTime(Players.Blue.currentTime))
    total2:setText(formatTime(Players.Blue.totalTime))
    counter2:setText(Players.Blue.counter)
end

function love.draw()
    gooi.draw()
end

function love.mousereleased(x, y, button) gooi.released() end
function love.mousepressed(x, y, button)  gooi.pressed() end

function love.textinput(text)
    gooi.textinput(text)
end
function love.keypressed(key, scancode, isrepeat)
    gooi.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        quit()
    end
end
function love.keyreleased(key, scancode)
    gooi.keyreleased(key, scancode)
end

function quit()
    love.event.quit()
end
