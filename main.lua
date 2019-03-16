require "love"
require "gooi"
require "img_button"

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

function showUI(visible)
    grid:setVisible(visible)
    toolbar:setVisible(visible)

    if visible then
        if CounterState.status == COUNTER_PAUSED or
            CounterState.status == COUNTER_OFF then
            btnStart:setVisible(true)
            btnPause:setVisible(false)
        else
            btnStart:setVisible(false)
            btnPause:setVisible(true)
        end
    end
end

function love.load()
    Players = {}
    Players.Red = Player:new()
    Players.Blue = Player:new()

    love.graphics.setBackgroundColor(0.15, 0.15, 0.15)
    love.graphics.setDefaultFilter("nearest", "nearest", 0)

    styles = {
        small = {
            font = love.graphics.newFont(26),
            showBorder = false
        },
        big = {
            font = love.graphics.newFont(144),
            showBorder = false
        }
    }
    colors = {
        blue = "#29aae2",
        red = "#e84a99",
        green = "#7fe84a",
        white = "#ffffff",
        bg = "#747d47"
    }

    toolbar = gooi.newPanel({x = 0, y = 0, w = 800, h = 80, layout = "game"})

    btnReset = gooi.newImgButton({image = love.graphics.newImage("data/button_reset.png")})
    btnQuit = gooi.newImgButton({image = love.graphics.newImage("data/button_quit.png")})
    btnStart = gooi.newImgButton({image = love.graphics.newImage("data/button_start.png")})
    btnPause = gooi.newImgButton({image = love.graphics.newImage("data/button_pause.png")})

    toolbar:add(btnQuit, "t-l")
    toolbar:add(btnReset, "t-l")
    toolbar:add(btnStart, "t-r")
    toolbar:add(btnPause, "t-r")

    btnPause:setVisible(false)

    grid = gooi.newPanel({x = 0, y = 80, w = 800, h = 400, layout = "grid 8x2"})
    grid:setRowspan(1, 1, 4):setRowspan(1, 2, 4)

    gooi.setStyle(styles["big"])
    counter1 = gooi.newButton({text = "0"}):center():fg(colors["red"]):setOpaque(false)
    counter2 = gooi.newButton({text = "0"}):center():fg(colors["blue"]):setOpaque(false)
    gooi.setStyle(styles["small"])
    timer1 = gooi.newLabel({text = "0:00"}):center():fg(colors["white"]):setOpaque(false)
    timer2 = gooi.newLabel({text = "0:00"}):center():fg(colors["white"]):setOpaque(false)
    total1 = gooi.newLabel({text = "0:00"}):center():fg(colors["red"]):setOpaque(false)
    total2 = gooi.newLabel({text = "0:00"}):center():fg(colors["blue"]):setOpaque(false)
    gooi.setStyle({font = gooi.defaultFont})

    grid:add(counter1)
    grid:add(counter2)
    grid:add(timer1, "6,1")
    grid:add(timer2, "6,2")
    grid:add(total1, "7,1")
    grid:add(total2, "7,2")

    btnQuit:onRelease(
        function()
            showUI(false)

            gooi.confirm({
                text = "Sure?",
                ok = function()
                    quit()
                end,
                cancel = function()
                    showUI(true)
                end
            })
        end
    )
    btnReset:onRelease(
        function()
            showUI(false)

            gooi.confirm({
                text = "Sure?",
                ok = function()
                    CounterState.status = COUNTER_OFF
                    CounterState.player = nil
                    Players.Red:reset()
                    Players.Blue:reset()
                    timer1:fg(colors["white"])
                    timer2:fg(colors["white"])
                    showUI(true)
                    btnStart:setVisible(true)
                    btnPause:setVisible(false)
                end,
                cancel = function()
                    showUI(true)
                end
            })
        end
    )
    btnPause:onRelease(
        function()
            if CounterState.status == COUNTER_ON then
                CounterState.status = COUNTER_PAUSED
                btnStart:setVisible(true)
                btnPause:setVisible(false)
            end
        end
    )
    btnStart:onRelease(
        function()
            if CounterState.status == COUNTER_PAUSED then
                CounterState.status = COUNTER_ON
                btnStart:setVisible(false)
                btnPause:setVisible(true)
            elseif CounterState.status == COUNTER_OFF then
                btnStart:setVisible(false)
                btnPause:setVisible(true)

                showUI(false)

                gooi.confirm({
                    text = "Who starts?",
                    cancel = function()
                        CounterState.status = COUNTER_ON
                        switchPlayer(Players.Red)
                        CounterState.player:reset()
                        CounterState.player:inc()
                        showUI(true)
                    end,
                    ok = function()
                        CounterState.status = COUNTER_ON
                        switchPlayer(Players.Blue)
                        CounterState.player:reset()
                        CounterState.player:inc()
                        showUI(true)
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
    local font = love.graphics.getFont()
    gooi.draw()

    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("FPS: "..love.timer.getFPS(), 8, 460)
end

function love.touchreleased(id, x, y, dx, dy, pressure) gooi.released() end
function love.touchpressed(id, x, y, dx, dy, pressure)  gooi.pressed() end
function love.mousereleased(x, y, button) gooi.released() end
function love.mousepressed(x, y, button)  gooi.pressed() end
function love.textinput(text) gooi.textinput(text) end

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
