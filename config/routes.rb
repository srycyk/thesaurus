
Thesaurus::Application.routes.draw do
  get "definitions/index"

  match "definitions/find", via: %w(post get)

  match "definitions/show", via: %w(post get)

  get "definitions/random"

  get "definitions/xref"

  get "definitions/phrases"

  get "definitions/clear_selected"
  get "definitions/sort_selected"
  get "definitions/remove_selected"

  root :to => 'definitions#index'
end
