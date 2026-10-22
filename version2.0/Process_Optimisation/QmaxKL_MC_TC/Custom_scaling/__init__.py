from omlt.scaling import ScalingInterface

def convert_to_dict(x) -> dict:
    if isinstance(x, dict):
        return dict(x)
    return dict(enumerate(x))

class MinMaxScaling(ScalingInterface):
    r"""MinMaxScaling interface.

    This scaling object represents the following scaling equations 
    for inputs (x) and outputs (y):

    .. math::
        \begin{align*}
        x_i^{scaled} &= \frac{x_i - x_i^{min}}{x_i^{max} - x_i^{min}} \\
        y_i^{scaled} &= \frac{y_i - y_i^{min}}{y_i^{max} - y_i^{min}}
        \end{align*}

    Parameters
    ----------
    min_inputs : array-like
        Minimum values for each input
    max_inputs : array-like
        Maximum values for each input
    min_outputs : array-like
        Minimum values for each output
    max_outputs : array-like
        Maximum values for each output
    """

    def __init__(self, min_inputs, max_inputs, min_outputs, max_outputs):
        super().__init__()
        self.__x_min = convert_to_dict(min_inputs)
        self.__x_max = convert_to_dict(max_inputs)
        self.__y_min = convert_to_dict(min_outputs)
        self.__y_max = convert_to_dict(max_outputs)

        for k in self.__x_min:
            if self.__x_max[k] <= self.__x_min[k]:
                raise ValueError(
                    f"max_inputs must be greater than min_inputs at index {k}"
                )
        for k in self.__y_min:
            if self.__y_max[k] <= self.__y_min[k]:
                raise ValueError(
                    f"max_outputs must be greater than min_outputs at index {k}"
                )

    def get_scaled_input_expressions(self, input_vars):
        """Get the scaled input expressions of the input variables."""
        sorted_keys = sorted(input_vars.keys())
        if sorted(self.__x_min) != sorted_keys or sorted(self.__x_max) != sorted_keys:
            raise ValueError("Keys in input_vars do not match keys in min/max inputs.")
        x = input_vars
        return {
            k: (x[k] - self.__x_min[k]) / (self.__x_max[k] - self.__x_min[k])
            for k in x
        }

    def get_unscaled_input_expressions(self, scaled_input_vars):
        """Get the unscaled input expressions of the scaled input variables."""
        sorted_keys = sorted(scaled_input_vars.keys())
        if sorted(self.__x_min) != sorted_keys or sorted(self.__x_max) != sorted_keys:
            raise ValueError(
                "Keys in scaled_input_vars do not match keys in min/max inputs."
            )
        sx = scaled_input_vars
        return {
            k: sx[k] * (self.__x_max[k] - self.__x_min[k]) + self.__x_min[k]
            for k in sx
        }

    def get_scaled_output_expressions(self, output_vars):
        """Get the scaled output expressions of the output variables."""
        sorted_keys = sorted(output_vars.keys())
        if sorted(self.__y_min) != sorted_keys or sorted(self.__y_max) != sorted_keys:
            raise ValueError("Keys in output_vars do not match keys in min/max outputs.")
        y = output_vars
        return {
            k: (y[k] - self.__y_min[k]) / (self.__y_max[k] - self.__y_min[k])
            for k in y
        }

    def get_unscaled_output_expressions(self, scaled_output_vars):
        """Get the unscaled output expressions of the scaled output variables."""
        sorted_keys = sorted(scaled_output_vars.keys())
        if sorted(self.__y_min) != sorted_keys or sorted(self.__y_max) != sorted_keys:
            raise ValueError(
                "Keys in scaled_output_vars do not match keys in min/max outputs."
            )
        sy = scaled_output_vars
        return {
            k: sy[k] * (self.__y_max[k] - self.__y_min[k]) + self.__y_min[k]
            for k in sy
        }
