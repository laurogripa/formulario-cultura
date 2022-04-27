require 'csv'
require 'active_support/all'
require_relative './inflections'
require 'magic_cloud'

form = CSV.read('formulario.csv')

# Índices dos campos abertos
# 4  => "Qual gênero você se identifica? (homem cis, mulher cis, mulher trans, homem trans, travesti, não binário e etc)"
# 5  => "Qual cor você se identifica?"
# 6  => "Qual sua sexualidade? (Lésbica, Gay, Bissexual, Pansexual, Heterossexual)"
# 9  => "Descreva em detalhes as atividades culturais que você faz em Joinville"
# 10 => "Que espaços você frequenta para exercer suas atividades culturais?"
# 11 => "Você faz parte de algum grupo, escola ou coletivo que produz Cultura? Se sim, escreva o nome e descreva o tipo de atividade realizada nele."
# 12 => "Quais problemas você enfrenta no seu cotidiano como artista/produtor(a) em Joinville?"
# 13 => "Quais soluções você enxerga para esses problemas?"
# 14 => "Quais lugares você frequenta no seu tempo livre? (Bares, praças, museus, teatros, casas de culto religioso, igrejas, casa de amigos, etc)"
# 15 => "Existe alguma coisa que te impede de consumir cultura de alguma maneira?"
# 16 => "Você tem alguma queixa como consumidor de cultura em Joinville?"
# 17 => "Quais soluções você enxerga para esses problemas?"
# 18 => "De quais tipos de espaço de Cultura você sente falta na cidade?"
# 19 => "Quais atividades você gostaria que existissem na cidade?"

def normalized_answers(answers, pos)
  answers.map { |a| a[pos]&.strip&.downcase || 'sem resposta' }
end

def generate_word_cloud(words, name)
  p words
  words = words.group_by{|a| a}.map{|k,v| [k, v.count]}.reject{|(_, count)| count < 3}
  cloud = MagicCloud::Cloud.new(words, rotate: :free, scale: :log)
  img = cloud.draw(960, 600) #default height/width
  img.write("#{name}.png")
end

answers = form.drop(1)


gender = normalized_answers(answers, 4)
# TODO: agrupar valores (ex: 'não binárie' junto com 'não-binário')
#
# Exemplo de como contar os valores de cada resposta:
# p genders.group_by{|a| a}.map{|k,v| [k, v.count]}
generate_word_cloud(gender, 'Gênero')

#----

ethnicity = normalized_answers(answers, 5)
# TODO: excluir respostas sem sentido (ex: roxo)
generate_word_cloud(ethnicity, 'Cor')


sexual_orientation = normalized_answers(answers, 6)
# TODO: agrupar valores
generate_word_cloud(sexual_orientation, 'Orientação Sexual')

##
# Nuvens de palavras
##
ignored_words = %w(e eu vezes minha para locais que de na no em todos todo rua pelo mal por outro ainda ano já mais
  seu sua seus suas de da do das dos mas os as etc ir o sou um como faço uma a meu vou algo muito com tem área é ao não
  algum estou parte nao até ter isso nas meio se também pra onde nós ele ela eles elas essa essas esses esse ou só ser
  mesmos mesmo mesma mesmas participei me bem pela fui outra sempre alguma sobre apenas dou tenho outros alguns algumas
  além muita toda pouco ano desde acredito seria partir tanto quem coisa à sei sem resposta)

# TODO: agrupar algumas palavras: ex 'praca' e 'praça'
{
  9 => "Artista e produtor - Descrição de atividades",
  10 => "Artista e produtor - Espaços que frequentam",
  11 => "Artista e produtor - Grupos que faz parte",
  12 => "Artista e produtor - Problemas do cotidiano",
  13 => "Artista e produtor - Soluções",
  14 => "Consumidor - Lugares que frequentam",
  15 => "Consumidor - Impecilhos pra consumir cultura",
  16 => "Consumidor - Queixas como consumidor",
  17 => "Consumidor - Soluções",
  18 => "Produtor - Espaços que sente falta",
  19 => "Consumidor - Atividades que gostaria que existissem"
}.each do |index, name|
  words = normalized_answers(answers, index).flat_map do |ans|
    ans.gsub(/[^[[:word:]] ]/, '').squeeze(' ').split(' ').uniq
  end.-(ignored_words).map(&:singularize)

  generate_word_cloud(words, name)
end
#
# Utilidade -- contar palavras, ignorando as que aparecem menos de 3 vezes
#
# p places
#   .group_by { _1 }
#   .map { |k, v| [k, v.count] }
#   .reject { |(_, count)| count < 3 }
#   .sort_by { |(_, count)| count }
#
