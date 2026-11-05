hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("smooth", {
    type = "bezier",
    points = { {0.25, 0.1}, {0.25, 1.0} },
})

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.5, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "smooth" })
hl.animation({ leaf = "borderangle", enabled = false })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "smooth", style = "slidefade 20%" })
