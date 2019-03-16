--function gooi.newImgButton(image, x, y, w, h)
function gooi.newImgButton(params)
    params = params or {}
    local b = {}
    local defaultText = ".........."
    local theH = gooi.getFont():getHeight()

    local x, y, w, h = gooi.checkBounds(
        defaultText,
        params.x or 0,
        params.y or 0,
        params.w or params.image:getWidth(),
        params.h or params.image:getHeight(),
        "img_button"
    )

    b = component.new("img_button", x, y, w, h, params.group)
    b.opaque = false
    b.image = params.image

    function b:rebuild()
    end

    function b:setText(value)
        return self
    end

    function b:largerLine()
    end

    function b:drawSpecifics(fg)
        love.graphics.setColor(fg)
        love.graphics.draw(self.image, self.x, self.y)
    end
    function b:left()
        return self
    end
    function b:center()
        return self
    end
    function b:right()
        return self
    end

    function b:setIcon(icon)
        return self
    end
    return gooi.storeComponent(b, id)
end
