FROM php:5.6-apache

# APT 自动安装PHP相关的依赖包,如需其他依赖包在此添加
RUN apt-get update -q && \
    apt-get install -yq \
        libmcrypt-dev \
        libz-dev \
        git \
        wget && \

    #  Docker Hub 官方 PHP 镜像内置命令，安装 PHP 拓展
    docker-php-ext-install \
        mcrypt \
        mbstring \
        zip && \

    # 用完包管理器后安排打扫卫生可以显著的减少镜像大小.
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \

    # 安装Composer,此物是PHP用来管理依赖关系的工具.
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 配置 composer 执行.
ENV PATH=$PATH:~/.composer/vendor/bin


# 开启 Url 重写模块
# 配置默认放置 App 的目录
RUN a2enmod rewrite && \
    mkdir -p /app && \
    rm -fr /var/www/html && \
    ln -s /app/public /var/www/html

WORKDIR /app

# 预先加载 Composer 包依赖，优化 Docker 构建镜像的速度
COPY ./composer.json /app/
COPY ./composer.lock /app/
RUN composer install  --no-autoloader --no-scripts

# 复制代码到 App 目录
COPY . /app

# 执行 Composer 自动加载和相关脚本
# 修改目录权限
RUN composer install && \
    chown -R www-data:www-data /app && \
    chmod -R 0777 /app/storage


