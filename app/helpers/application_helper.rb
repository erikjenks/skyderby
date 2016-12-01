# coding: utf-8
module ApplicationHelper
  def page_title(title)
    base_title = I18n.t 'static_pages.index.title'
    if title.empty?
      'Skyderby: ' + base_title
    else
      title + ' - Skyderby'
    end
  end

  def lang_presentation(lang_code)
    {
      en: 'English',
      ru: 'Русский',
      de: 'Deutsch',
      es: 'Spanish'
    }[lang_code]
  end

  def lang_menu
    content_tag(:ul, class: ('dropdown-menu'), role: ('menu')) do
      I18n.available_locales.each do |loc|
        locale_param = request.path == root_path ? root_path(locale: loc) : params.to_h.merge(locale: loc)
        concat content_tag(:li, (link_to lang_presentation(loc), locale_param), class: (I18n.locale == loc ? 'active' : ''))
      end
    end
  end

  def bootstrap_class_for(flash_type)
    case flash_type
      when 'success'
        'alert-success' # Green
      when 'error'
        'alert-danger' # Red
      when 'alert'
        'alert-warning' # Yellow
      when 'notice'
        'alert-info' # Blue
      else
        flash_type.to_s
    end
  end
end
