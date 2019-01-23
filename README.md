# rubymeta

This is my "handbook" of somewhat "meta" code I wrote to solve some specific tasks.
Example: instead of writing `'#{page={page}&per_page={per_page}(...)'` to form an URL query string, you can come up with something like:
```ruby
params = ["page", "per_page", "order_by", "order_type"].map do |param|
  param + "=" + binding.local_variable_get(param).to_s
end.join("&")
```
This only makes life easier, but there are/were cases when such "meta" code was a must, so I'm keeping this for posterity.