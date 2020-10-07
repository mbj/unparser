#/usr/bin/bash -ex

bundle exec mutant                                                    \
  --zombie                                                            \
  --ignore-subject 'Unparser::CLI*'                                   \
  --ignore-subject 'Unparser::Emitter#emit_comments'                  \
  --ignore-subject 'Unparser::Emitter#emit_comments_before'           \
  --ignore-subject 'Unparser::Emitter#emit_eol_comments'              \
  --ignore-subject 'Unparser::Emitter.handle'                         \
  --ignore-subject 'Unparser::Emitter::Args#normal_arguments'         \
  --ignore-subject 'Unparser::Emitter::Args#shadowargs'               \
  --ignore-subject 'Unparser::Emitter::Array#emitters'                \
  --ignore-subject 'Unparser::Emitter::Binary#writer'                 \
  --ignore-subject 'Unparser::Emitter::Block#target_writer'           \
  --ignore-subject 'Unparser::Emitter::Class#dispatch'                \
  --ignore-subject 'Unparser::Emitter::Class#local_variable_scope'    \
  --ignore-subject 'Unparser::Emitter::Def#local_variable_scope'      \
  --ignore-subject 'Unparser::Emitter::HashPattern#write_symbol_body' \
  --ignore-subject 'Unparser::Emitter::LocalVariableRoot*'            \
  --ignore-subject 'Unparser::Emitter::LocalVariableRoot.included'    \
  --ignore-subject 'Unparser::Emitter::Module#local_variable_scope'   \
  --ignore-subject 'Unparser::Emitter::Root#local_variable_scope'     \
  --ignore-subject 'Unparser::Emitter::Send#writer'                   \
  --ignore-subject 'Unparser::Validation.from_string'                 \
  --ignore-subject 'Unparser::Writer.included'                        \
  --ignore-subject 'Unparser::Writer::Binary#left_emitter'            \
  --ignore-subject 'Unparser::Writer::Binary#right_emitter'           \
  --ignore-subject 'Unparser::Writer::Send#details'                   \
  --ignore-subject 'Unparser::Writer::Send#effective_writer'          \
  $*
