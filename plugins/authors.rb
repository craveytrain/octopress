module Jekyll
	class AuthorProfile < Page
		def initialize(site, base, dir, path)
			ext = File.extname path
			@site  = site
			@base  = base
			@dir   = dir
			@name  = "index#{ext}"
			author = File.basename path, ext

			self.process(@name)
			self.read_yaml(File.join(base, '_layouts'), 'author.html')
			self.read_yaml(File.dirname(path), File.basename(path))
			self.data['author'] = author
			self.data['title'] = "#{self.data['name']} | #{self.data['role']}"
		end
	end

	class GenerateProfile < Generator
		safe true
		priority :normal

		def generate(site)
			if site.layouts.key? 'author'
				dir = 'authors'
				Dir[File.join(site.source, "_#{dir}", "*")].each { |author| write_author_profile(site, File.join(dir, File.basename(author, '.markdown')), author) }
			end
		end

		def write_author_profile(site, dir, path)
			index = AuthorProfile.new(site, site.source, dir, path)
			index.render(site.layouts, site.site_payload)
			index.write(site.dest)
			site.pages << index
		end
	end

	class AuthorsTag < Liquid::Tag

		def initialize(tag_name, text, tokens)
			super
			@text   = text
			@tokens = tokens
		end

		def render(context)
			site = context.environments.first["site"]
			page = context.environments.first["page"]

			if page
				authors = page['author']
				authors = [authors] if authors.is_a?(String)

				"".tap do |output|
					if authors
						authors.each { |author| output << "<a href=\"#{site['root']}/authors/#{author.downcase.gsub(' ', '-')}/\">#{author}</a>" }
					else
						output << site['author']
					end
				end
			end
		end
	end
end

Liquid::Template.register_tag('author', Jekyll::AuthorsTag)