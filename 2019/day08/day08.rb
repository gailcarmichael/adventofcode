class Image
    def initialize(width, height, raw_pixel_string)
        @width = width
        @height = height
        parse_raw_pixel_data(raw_pixel_string.split("").map(&:to_i))
    end

    def digit_count_for_layer(layer, digit)
        result = digit_counts.select{|key,value| key[0] == layer && key[1] == digit}[[layer,digit]]
        result ? result : 0
    end

    def layer_with_fewest_of_digit(digit)
        digit_counts.select{|key,_| key[1] == digit}.min_by{|key, value| value}[0][0]
    end

    def to_s
        values = decoded_image
        result = ""
        (0..@height-1).each do |y|
            (0..@width-1).each do |x|
                result += (values[[x,y]] == 0) ? " " : "*"
            end
            result += "\n"
        end
        result
    end

    private

    def decoded_image
        decoded_image = Hash.new
        (0..@height-1).each do |y|
            (0..@width-1).each do |x|
                (0..@num_layers).each do |layer_num|
                    decoded_image[[x,y]] ||= @image_data[[layer_num,x,y]]
                    decoded_image[[x,y]] = @image_data[[layer_num,x,y]] if decoded_image[[x,y]] == 2
                end
            end
        end
        decoded_image
    end

    def digit_counts
        digit_count_for_layer = Hash.new(0)
        @image_data.each do |coord, pixel_value|
            digit_count_for_layer[[coord[0], pixel_value]] += 1
        end
        digit_count_for_layer
    end

    def parse_raw_pixel_data(raw_pixel_array)
        @num_layers = raw_pixel_array.length / (@width * @height)
        @image_data = Hash.new

        (0..@num_layers-1).each do |layer_num|
            (0..@height-1).each do |y|
                (0..@width-1).each do |x|
                    raw_index = (layer_num*@width*@height) + (y*@width + x)
                    @image_data[[layer_num,x,y]] = raw_pixel_array[raw_index]
                end
            end
        end
    end
end

# image = Image.new(3, 2, "123456789012")
# p image.digit_count_for_layer(0, 0)
# p image.digit_count_for_layer(1, 0)

# image = Image.new(25, 6, File.read("day08-input.txt").strip)
# layer_fewest_zeros = image.layer_with_fewest_of_digit(0)
# p image.digit_count_for_layer(layer_fewest_zeros, 1) * image.digit_count_for_layer(layer_fewest_zeros, 2)

# puts Image.new(2,2,"0222112222120000")


puts Image.new(25, 6, File.read("day08-input.txt").strip)