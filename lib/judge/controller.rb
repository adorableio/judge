require 'uri'

module Judge
  module Controller

    def self.included(base)
      base.clear_respond_to
      base.respond_to(:json)
    end

    def validation(params)
      norm_params = normalized_params(params)
      if params_present?(norm_params) && params_exposed?(norm_params)
        Validation.new(norm_params)
      else
        NullValidation.new(norm_params)
      end
    end

    private

      REQUIRED_PARAMS = %w{klass attribute value kind}

      def params_exposed?(params)
        Judge.config.exposed?(params[:klass], params[:attribute])
      end

      def params_present?(params)
        params.keys == REQUIRED_PARAMS && params.values.all?
      end

      def normalized_params(params)
        params.dup.keep_if { |k| REQUIRED_PARAMS.include?(k) }.tap do |params|
          params[:klass]     = find_klass(params[:klass]) if params[:klass]
          params[:attribute] = params[:attribute].to_sym  if params[:attribute]
          params[:value]     = URI.decode(params[:value]) if params[:value]
          params[:kind]      = params[:kind].to_sym       if params[:kind]
        end
      end

      def find_klass(name)
        Module.const_get(name.classify)
      rescue NameError
        nil
      end

  end
end
