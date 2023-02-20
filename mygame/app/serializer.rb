def serialize_object_to_json object
    if object.is_a? Hash
        return serialize_hash_to_json object
    elsif object.is_a? Array
        return serialize_array_to_json object
    elsif object.is_a? String
        return serialize_string_to_json object
    elsif object.is_a? Numeric
        return serialize_numeric_to_json object
    elsif object.is_a? TrueClass
        return serialize_true_to_json object
    elsif object.is_a? FalseClass
        return serialize_false_to_json object
    elsif object.is_a? NilClass
        return serialize_nil_to_json object
    else
        return serialize_object_to_json object
    end
end

def serialize_hash_to_json hash
    json = "{"
    hash.each do |key, value|
        json += "\"#{key}\": #{serialize_object_to_json value},"
    end
    json = json[0..-2]
    json += "}"
    return json
end

def serialize_array_to_json array
    json = "["
    array.each do |value|
        json += "#{serialize_object_to_json value},"
    end
    json = json[0..-2]
    json += "]"
    return json
end

def serialize_string_to_json string
    return "\"#{string}\""
end

def serialize_numeric_to_json numeric
    return numeric.to_s
end

def serialize_true_to_json true_class
    return "true"
end

def serialize_false_to_json false_class
    return "false"
end

def serialize_nil_to_json nil_class
    return "null"
end

def serialize_state state
    return serialize_object_to_json state
end

def convert_hash_keys_to_symbols hash
    new_hash = {}
    hash.each do |key, value|
        if value.is_a? Hash
            new_hash[key.to_sym] = convert_hash_keys_to_symbols value
        else
            new_hash[key.to_sym] = value
        end
    end
    return new_hash
end

def convert_array_of_hashes_to_symbols array
    new_array = []
    array.each do |hash|
        new_array << convert_hash_keys_to_symbols(hash)
    end
    return new_array
end