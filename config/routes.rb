
Thesaurus::Application.routes.draw do
  get "definitions/index"

  match "definitions/find", via: %w(post get)

  get "definitions/show"

  get "definitions/random"

  get "definitions/xref"

  get "definitions/phrases"

  get "definitions/clear_selected"
  get "definitions/sort_selected"
  get "definitions/remove_selected"

  root :to => 'definitions#index'
end
