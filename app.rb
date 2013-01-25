require 'sinatra/base'
require 'picky'
require File.expand_path '../logging', __FILE__

module Picky
  module Sinatra
      
    module IndexActionsHotfix
      
      def self.extended base
        # Updates the given item and returns HTTP codes:
        #  * 200 if the index has been updated or no error case has occurred.
        #  * 404 if the index cannot be found.
        #  * 400 if no data or item id has been provided in the data.
        #
        # Note: 200 returns no data yet.
        #
        base.put '/' do
          index_name = params['index']
          begin
            index = Picky::Indexes[index_name.to_sym]
            data = params['data']
            return 400 unless data
            data && index.replace_from(MultiJson.decode data) && 200
          rescue IdNotGivenException
            400
          rescue StandardError
            404
          end
        end
        
        # Deletes the given item and returns:
        #  * 200 if the index has been updated or no error case has occurred.
        #  * 404 if the index cannot be found.
        #  * 400 if no data or item id has been provided in the data.
        #
        # Note: 200 returns no data yet.
        #
        base.delete '/' do
          index_name = params['index']
          begin
            index = Picky::Indexes[index_name.to_sym]
            data = MultiJson.decode params['data']
            id = data['id']
            id ? index.remove(id) && 200 : 400
          rescue StandardError
            404
          end
        end
      end
      
    end
    
  end
end

class ZenodotosSearch < Sinatra::Base
  
  
  extend Picky::Sinatra::IndexActionsHotfix

  BookIndex = Picky::Index.new :books do
    #backend  Picky::Backends::SQLite.new(realtime: true)
    category "titel"
    category "autor"
    category "hrsg"
    category "signatur"
    category "jahr"
    category "kommentar"
    category "anmerkungen"
    category "auflage"
    category "baende"
    category "bearbeiter"
    category "bestelladresse"
    category "drehbuch"
    category "format"
    category "inhalt"
    category "sprache"
    category "literaturvorlage"
    category "nebensignatur"
    category "ort"
    category "platz"
    category "preis"
    category "publikationsart"
    category "reihe"
    category "seiten"
    category "stifter"
    category "verlag"
    category "standort"
    category "datensatz"
    category "aufnahmedatum"
    category "issn"
    category "isbn"
    category "invent"
    category "autor_japanisch"
    category "hrsg_japanisch"
    category "drehbuch_japanisch"
    category "reihe_japanisch"
    category "titel_japanisch"
    category "verlag_japanisch"
    category "literaturvorlage_japanisch"
    category "nacsis_japanisch"
    category "jid"
    category "nacsis_url"
    category "interne_notizen"
    category "created_at"
    category "updated_at"
    category "vormerken"
    category "altes_datum"

    indexing  removes_characters: /[^\p{Han}\p{Hiragana}\p{Katakana}a-zA-Z0-9\.\s]/u,
              substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
              splits_text_on: /\s/u
  end

  BookSearch = Picky::Search.new BookIndex do
    searching removes_characters: /[^\p{Han}\p{Hiragana}\p{Katakana}a-zA-Z0-9\.:\s]/u,
              substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
              splits_text_on: /\s/u

    boost [:titel] => +6,
          [:titel_japanisch] => +6,
          [:autor] => +4,
          [:autor_japanisch] => +4

  end

  BorrowerIndex = Picky::Index.new :borrowers do
    #backend  Picky::Backends::SQLite.new(realtime: true)
    category "anschrift"
    category "bearbeiter"
    category "email"
    category "heimatanschrift"
    category "matrikelnr"
    category "mobiltelefon"
    category "name"
    category "status"
    category "telefon"
    category "telefon2"
    category "ub_nr"
    category "vermerke"
  end

  BorrowerSearch = Picky::Search.new BorrowerIndex

  get %r{\A/books\z} do
    query = params['query']['query']
    ids = params['query']['ids']
    results = BookSearch.search query, ids || 20
    results.to_json
  end
  get %r{\A/borrowers\z} do
    query = params['query']['query']
    ids = params['query']['ids']
    results = BorrowerSearch.search query, ids || 20
    results.to_json
  end

  begin
    BookIndex.load
    BorrowerIndex.load
  rescue => e
    puts "Index could not be loaded: #{e}"
  end

  at_exit do
    BookIndex.dump
    BorrowerIndex.dump
  end

end
