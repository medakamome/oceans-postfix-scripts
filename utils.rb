#! /usr/bin/ruby
# coding: utf-8

module Utils

    #--------------------------------
    # フッター削除
    #--------------------------------
    def delete_footer(str, footerCount)
        
        # 行数カウント
        totalCount = str.scan(/^(.)*$/).size

        # フッター削除
        result = ''

        count = 0
        str.lines { |line|
            count += 1
            if ( count <= totalCount - footerCount) then
                result += line
            end
        } 
        return result
    end
    
    module_function :delete_footer
end
