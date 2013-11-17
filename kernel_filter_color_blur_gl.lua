local kernel = {}
kernel.language = "glsl"

kernel.category = "filter"

kernel.name = "colorBlurGaussian"

kernel.graph =
{
   nodes = {
      horizontal = { effect="filter.blurHorizontal", input1="paint1" },
      vertical = { effect="filter.blurVertical", input1="horizontal" },
      monotone = { effect="filter.monotone", input1="vertical" },
   },
   output = "monotone",
}

return kernel