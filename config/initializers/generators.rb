Rails.application.config.generators do |g|
	g.helper nil
	g.assets nil
	g.view_specs nil
	g.template_engine :haml
	g.test_framework  false, fixture: false
	g.stylesheets     nil 
	g.javascripts     nil 
	g.jbuilder false
end
