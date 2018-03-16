Rails.application.routes.draw do
	root 'crw#location_picker'
	get 'tehran/:id', to: 'crw#index'
end
