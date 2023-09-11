# This funcition will take two locations and proudce differences between the two locations
# 1. Files from path one not in two
# 2. Files from path two not in one
# TODO: 
## 1. make sure that the paths exist, if not say which ones are false
function file_name_diffs(path_one::String, path_two::String)
    
    list_one = readdir(path_one)

    list_one = map(x -> split(x,".")[1],list_one)
    
    list_two = readdir(path_two)
    
    list_two = map(x -> split(x,".")[1],list_two)
    
    exclusion = Dict()
    
    exclusion["list_one_items_not_in_two"] = list_one[(!in).(list_one, Ref(list_two))] 
        
    exclusion["list_two_items_not_in_one"] = list_two[(!in).(list_two, Ref(list_one))]
    
    return(exclusion)
end


# Input: readlines() type object for a fasta file
# output:  A dict type object where the fasta headers are keys and the sequences are values
# TODO:
## 1. Make sure that is is indeed a fasta file
## 2. Make sure that the file in sequential and not iterleaved. Convert to interleaved 
function hasta_file(fasta_lines)
    #determine fastaness #TODO
    
    hasta_dict = Dict{String,String}()
    for (i, line) in enumerate(fasta_lines)
        if startswith(line,">")
            hasta_dict[line] = fasta_lines[i+1]
        else
            continue
        end
    end
    
    return(hasta_dict)
end

# Input: A dict type object where the keys are gene ID and values are sequences
# Output: A dict type object where the keys are gene IDs and values are sequence length
function hasta_counts(hasta_dict)
    fasta_count_dict = Dict{String, Int32}()

    for (key,value) in hasta_dict
        fasta_count_dict[key] = length(value)
    end

    return(fasta_count_dict)
end

#Input: A list
# Output: Most common number in the list
function most_common(list)
  counts = Dict()
  for item in list
    if haskey(counts, item)
      counts[item] += 1
    else
      counts[item] = 1
    end
  end

  most_common_item = ""
  max_count = 0
  for (item, count) in counts
    if count > max_count
      most_common_item = item
      max_count = count
    end
  end

  return most_common_item
end