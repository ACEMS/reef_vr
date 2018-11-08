library(r2vr)

image_path_3d <- "./images/120310281.jpg"
image_path_2d <- "./images/61010309601.jpg"

image_3d <- a_asset(.tag = "image",
                    id = "reef3d",
                    src = image_path_3d)
image_2d <- a_asset(.tag = "image",
                    id = "reef2d",
                    src = image_path_2d)

canvas_3d <- a_entity(.tag = "sky",
                      src = image_3d,
                      rotation = c(0, 90, 0))

canvas_frame <- a_entity(.tag = "plane",
                         height = 2.1,
                         width = 2.1,
                         position = c(0, 0, -0.1),
                         color = "yellow")

canvas_line <- a_entity(line = list(
                          start = c(-2.05, 0, -2),
                          end = c(4, 0, -3),
                          color = "yellow"))

canvas_2d <- a_entity(.tag = "plane",
                      src = image_2d,
                      height = 2,
                      width = 2,
                      position = c(-2.05, 1, -2),
                      rotation = c(0, 30, 0),
                      .children = list(canvas_frame))


tour <- a_scene(.children = list (canvas_3d, canvas_2d, canvas_line),
                .websocket = TRUE,
                .template = "empty" )
tour$serve()

a_kill_all_scenes()

