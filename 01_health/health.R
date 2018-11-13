library(r2vr)

## define 3d image assets
healthy_high_aes <- a_asset(.tag = "image",
                            id = "hha",
                            src = "./data/360-degree_Images/Heatlhy_high_aesthetic/120261897.jpg")


healthy_low_aes <- a_asset(.tag = "image",
                           id = "hla",
                           src = "./data/360-degree_Images/Heatlhy_low_aesthetic/100030039.jpg")


unhealthy_high_aes <- a_asset(.tag = "image",
                              id = "uha",
                              src = "./data/360-degree_Images/Unhealthy_high_aesthetic/130050093.jpg")

unhealthy_low_aes <- a_asset(.tag = "image",
                             id = "ula",
                             src = "./data/360-degree_Images/Unhealthy_low_aesthetic/130030287.jpg")

## define 2d image assets
healthy_aesthetic_2d <- a_asset(.tag = "image",
                               id = "hha2d",
                               src = "./data/2D_images/120261897.jpg")

healthy_low_aesthetic_2d <- a_asset(.tag = "image",
                                    id = "hla2d",
                                    src = "./data/2D_images/100030039.jpg")

unhealthy_aesthetic_2d <- a_asset(.tag = "image",
                               id = "uha2d",
                               src = "./data/2D_images/1300050093.jpg")

unhealthy_low_aesthetic_2d <- a_asset(.tag = "image",
                                      id = "ula2d",
                                      src = "./data/2D_images/130030287.jpg")
## Image meta data
reef_contexts <- c("hha", "hla", "uha", "ula")
context_rotations <- list(list(x = 0, y = 170, z = 0),
                          list(x = 0, y = 0, z = 0),
                          list(x = 0, y = 0, z = 0),
                          list(x = 0, y = 270, z = 0))
line_ends <- list(list(x = -0.25 , y = -0.02 , z = -3.02),
                  list(x = -0.25 , y = -0.02 , z = -1.1),
                  list(x = -0.25 , y = -0.02 , z = -1.1),
                  list(x = -0.25 , y = -0.02 , z = -1.1))
text_descriptions <-
  list("A: 22  HC: 74  O: 4",
       "A: 56  HC: 22  O: 22",
       "A: 86  SC: 6   O: 8",
       "A: 70  HC: 20  O: 10"
       )
insets <- c("uha2d", "ula2d", "hha2d", "hla2d")

## A 360 sphere to render the reef images on
canvas_3d <- a_entity(.tag = "sky",
                      id = "canvas3d",
                      src = healthy_high_aes,
                      rotation = unlist(context_rotations[[1]]),
                      .assets = list(healthy_low_aes,
                                     unhealthy_low_aes,
                                     unhealthy_high_aes))

## A 2D plane to render the comparison images on
canvas_size = 2

frame <- a_entity(.tag = "plane",
                  width = 1.05 * canvas_size,
                  height = 1.05 * canvas_size,
                  position = c(0.01, 0, -0.01),
                  color = "yellow")

canvas_2d <- a_entity(.tag = "plane",
                      id = "canvas2d",
                      src = unhealthy_aesthetic_2d,
                      width = canvas_size,
                      height = canvas_size,
                      position = c(-3, 1.5, -0.5),
                      rotation = c(0, 80, 0),
                      visible = FALSE,
                      .children = list(frame),
                      .assets = list(healthy_aesthetic_2d,
                                     healthy_low_aesthetic_2d,
                                     unhealthy_low_aesthetic_2d))

## A line to point to reef
line <- a_entity(id = "line",
                 line = list(
                   start = c(-3, 0.6, -0.5),
                   end = unlist(line_ends[[1]]),
                   color = "yellow"),
                 visible = FALSE)

## A line pointing to a relevant area

## Ambient lighting
light <- a_entity(.tag = "light",
                  intensity = 1.2,
                  type = "ambient")

## Camera with a text display
camera <- a_entity(.tag = "camera",
                   .children = list(a_label(id = "coral_text",
                                            text = text_descriptions[[1]],
                                            scale = c(0.6, 0.6, 0.6),
                                            position = c(0, 0.6, -1),
                                            color = "white",
                                            visible = FALSE)))

## Where will we serve the scene?
LOCAL_IP <- "10.0.1.26"

## Setup the scene
tour <- a_scene(.children = list(light,
                                 camera,
                                 canvas_3d,
                                 canvas_2d,
                                 line),
                .websocket = TRUE,
                .websocket_host = LOCAL_IP,
                .template = "empty")

## interactive machinery
CONTEXT_INDEX <- 1

## Advance to next setting
go <- function(){
  CONTEXT_INDEX <<- ifelse(CONTEXT_INDEX + 1 > length(reef_contexts),
                          yes = 1,
                          no = CONTEXT_INDEX + 1)

  next_image <- reef_contexts[[CONTEXT_INDEX]]
  next_inset <- insets[[CONTEXT_INDEX]]

  ## Hide call outs and data
  pop(FALSE)

  tour$send_messages(list(
         a_update(id = "canvas3d",
                  component = "material",
                  attributes = list(src = paste0("#",next_image))),
         a_update(id = "canvas3d",
                  component = "rotation",
                  attributes = context_rotations[[CONTEXT_INDEX]]),
         a_update(id = "canvas2d",
                  component = "material",
                  attributes = list(src = paste0("#",next_inset))),
         a_update(id = "line",
                  component = "line",
                  attributes = list(end = line_ends[[CONTEXT_INDEX]])),
         a_update(id = "coral_text",
                  component = "text",
                  attributes = list(value = text_descriptions[[CONTEXT_INDEX]]))
       ))

}

## Show/Hide callouts
pop <- function(visible = TRUE){

  tour$send_messages(list(
         a_update(id = "line",
                  component = "visible",
                  attributes = visible),
         a_update(id = "canvas2d",
                  component = "visible",
                  attributes = visible),
         a_update(id = "coral_text",
                  component = "visible",
                  attributes = visible)))
}

begin <- function(){
tour$serve(host = LOCAL_IP)
}

end <- function(){
  a_kill_all_scenes()
}
