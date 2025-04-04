defmodule Policia.Seeds do
  @moduledoc """
  Módulo para cargar datos de prueba en la base de datos.
  """

  alias Policia.Repo
  alias Policia.Articles.Category
  alias Policia.Articles.Article

  def run do
    seed_categories()
    |> seed_articles()

    IO.puts("Seeds cargados correctamente.")
  end

  defp seed_categories do
    categories = [
      %{
        name: "Seguridad Ciudadana",
        slug: "seguridad-ciudadana",
        description:
          "Información sobre medidas y programas para garantizar la seguridad de la ciudadanía"
      },
      %{
        name: "Operativos Policiales",
        slug: "operativos-policiales",
        description: "Detalles sobre operativos realizados por la fuerza policial"
      },
      %{
        name: "Capacitación Policial",
        slug: "capacitacion-policial",
        description: "Noticias sobre formación y especialización del personal policial"
      },
      %{
        name: "Seguridad Vial",
        slug: "seguridad-vial",
        description: "Información sobre controles de tránsito y prevención de accidentes"
      },
      %{
        name: "Noticias Institucionales",
        slug: "noticias-institucionales",
        description: "Comunicados oficiales y eventos institucionales"
      }
    ]

    # Insertar categorías y devolver un mapa con los registros para uso posterior
    categorias_insertadas =
      Enum.map(categories, fn category_data ->
        {:ok, category} =
          %Category{}
          |> Category.changeset(category_data)
          |> Repo.insert(on_conflict: :nothing)

        # Si hubo conflicto, busca la categoría existente
        category =
          if is_nil(category.id) do
            Repo.get_by!(Category, slug: category_data.slug)
          else
            category
          end

        {category_data.slug, category}
      end)

    Map.new(categorias_insertadas)
  end

  defp seed_articles(categories) do
    # Lista de artículos para cada categoría
    articulos = [
      # Seguridad Ciudadana (3 artículos)
      %{
        title: "Nuevo sistema de monitoreo urbano reduce un 30% los delitos",
        content:
          "La implementación del nuevo sistema de monitoreo urbano con 200 cámaras de alta definición ha permitido reducir en un 30% los delitos contra la propiedad en el centro de la ciudad durante el último trimestre.

Este sistema, que cuenta con tecnología de reconocimiento facial y análisis de comportamiento, permite a los operadores identificar situaciones de riesgo en tiempo real y coordinar la respuesta policial de manera más eficiente.

'Este es un claro ejemplo de cómo la tecnología puede ser una aliada en la lucha contra el delito', expresó el Comisario General durante la presentación de los resultados del proyecto. El sistema continuará expandiéndose a otros barrios de la ciudad en los próximos meses.",
        author: "Departamento de Prensa",
        category_id: get_category_id(categories, "seguridad-ciudadana"),
        image_url: "/images/demo/security-cameras.jpg"
      },
      %{
        title: "Vecinos conforman red de alerta barrial en cinco nuevos barrios",
        content:
          "Cinco nuevos barrios se han sumado al programa 'Vecinos Alerta', una iniciativa que busca fortalecer los lazos comunitarios y mejorar la respuesta ante situaciones sospechosas.

La red, que funciona mediante grupos de WhatsApp coordinados por referentes barriales y supervisados por personal policial, ya cuenta con más de 2,000 vecinos que actúan como 'ojos adicionales' para la policía.

'No se trata de reemplazar a la policía, sino de colaborar con información valiosa que permita una respuesta más rápida y efectiva', explicó Martín López, coordinador del programa. Se espera que para fin de año, todos los barrios de la ciudad cuenten con al menos un grupo activo de esta red.",
        author: "Carolina Méndez",
        category_id: get_category_id(categories, "seguridad-ciudadana"),
        image_url: "/images/demo/neighborhood-watch.jpg"
      },
      %{
        title: "Lanzan aplicación para reportar incidentes de seguridad",
        content:
          "La Policía de Río Negro presentó hoy 'AlertaRN', una nueva aplicación móvil gratuita que permite a los ciudadanos reportar incidentes de seguridad de manera rápida y efectiva.

La app, disponible para dispositivos Android e iOS, permite enviar alertas georreferenciadas con fotos o videos, que son recibidas en tiempo real por el centro de monitoreo policial.

'Esta herramienta nos ayudará a tener una respuesta más rápida y precisa ante situaciones de emergencia', afirmó el jefe de la División Tecnología. Además de enviar reportes, los usuarios pueden recibir alertas sobre incidentes en su zona y acceder a consejos de seguridad personalizados.

La aplicación ha sido desarrollada con fondos provinciales y estará disponible para su descarga a partir del próximo lunes.",
        author: "Oficina de Comunicación Institucional",
        category_id: get_category_id(categories, "seguridad-ciudadana"),
        image_url: "/images/demo/mobile-app.jpg"
      },

      # Operativos Policiales (3 artículos)
      %{
        title: "Megaoperativo policial desbarata red de tráfico de drogas",
        content:
          "Un operativo conjunto entre la Policía de Río Negro y fuerzas federales logró desarticular una organización dedicada al tráfico de drogas que operaba en cuatro provincias del país.

Durante los 15 allanamientos simultáneos realizados esta madrugada, se detuvo a 12 personas, entre ellas dos líderes de la organización, y se secuestraron más de 100 kilos de sustancias ilícitas, vehículos de alta gama y armamento.

'Esta es una de las operaciones más importantes contra el narcotráfico en la región en los últimos años', destacó el ministro de Seguridad provincial. La investigación, que se extendió por más de seis meses, incluyó escuchas telefónicas, seguimientos encubiertos y análisis de movimientos financieros.

Los detenidos enfrentarán cargos por tráfico de estupefacientes, asociación ilícita y lavado de activos.",
        author: "Lucía Fernández",
        category_id: get_category_id(categories, "operativos-policiales"),
        image_url: "/images/demo/police-operation.jpg"
      },
      %{
        title: "Operativo Verano seguro recupera 15 vehículos robados",
        content:
          "El 'Operativo Verano Seguro', implementado en las rutas y principales centros turísticos de la provincia, ha permitido la recuperación de 15 vehículos robados y la detención de 8 personas vinculadas a una banda dedicada al robo y posterior adulteración de automotores.

Los controles, que incluyen verificación de documentación y números de chasis a través de dispositivos móviles conectados en tiempo real con la base de datos nacional, continuarán hasta finales de febrero.

'Hemos incrementado un 40% los controles respecto al año pasado, con resultados muy positivos', señaló el jefe de la División Prevención del Delito Automotor. Además de la recuperación de vehículos, el operativo ha permitido detectar otras infracciones como transporte ilegal de mercaderías y documentación apócrifa.",
        author: "Javier Rodríguez",
        category_id: get_category_id(categories, "operativos-policiales"),
        image_url: "/images/demo/car-checkpoint.jpg"
      },
      %{
        title: "Desarticulan banda dedicada a estafas telefónicas a adultos mayores",
        content:
          "Un importante operativo policial permitió desbaratar una organización criminal que se dedicaba a estafar a adultos mayores mediante llamadas telefónicas fingiendo ser familiares en problemas.

Las investigaciones, que se extendieron por más de tres meses, culminaron con allanamientos simultáneos en cinco domicilios donde se detuvo a siete personas y se secuestraron teléfonos celulares, computadoras, documentación falsa y dinero en efectivo.

'Los detenidos operaban con un guion muy elaborado, estudiaban a sus víctimas y contaban con información precisa que les permitía ganar su confianza', explicó el jefe de la División Delitos Económicos.

Se estima que la banda habría estafado a más de 50 personas en los últimos seis meses, con un perjuicio económico que supera los 15 millones de pesos. La policía recuerda a la población que ante llamadas sospechosas, lo mejor es cortar y contactar directamente al familiar mencionado.",
        author: "Departamento de Investigaciones",
        category_id: get_category_id(categories, "operativos-policiales"),
        image_url: "/images/demo/phone-scam.jpg"
      },

      # Capacitación Policial (3 artículos)
      %{
        title: "Graduación de 120 nuevos oficiales de policía",
        content:
          "Esta mañana se llevó a cabo la ceremonia de graduación de 120 nuevos oficiales de la Policía de Río Negro, quienes completaron su formación en la Escuela de Cadetes 'Comisario General Juan Carlos Castillo'.

Los flamantes oficiales, entre los que se encuentran 65 mujeres, recibieron capacitación en diferentes áreas como derechos humanos, mediación comunitaria, técnicas de investigación criminal y primeros auxilios, además del entrenamiento físico y táctico tradicional.

'Hoy comienza para ustedes un camino de servicio y compromiso con la comunidad', expresó el Ministro de Seguridad durante la ceremonia. 'La sociedad espera de ustedes profesionalismo, ética y vocación de servicio'.

Los nuevos oficiales serán destinados a diferentes comisarías y unidades especiales de la provincia, con especial énfasis en reforzar la presencia policial en zonas turísticas durante la temporada estival.",
        author: "Dirección de Formación Policial",
        category_id: get_category_id(categories, "capacitacion-policial"),
        image_url: "/images/demo/police-graduation.jpg"
      },
      %{
        title: "Personal policial recibe capacitación en primeros auxilios psicológicos",
        content:
          "Un grupo de 50 efectivos policiales participó del curso 'Primeros Auxilios Psicológicos en Situaciones de Crisis', dictado por profesionales del Departamento de Salud Mental de la provincia.

La capacitación, que tuvo una duración de 40 horas, brindó herramientas para el abordaje inicial de personas afectadas por situaciones traumáticas como accidentes, catástrofes o hechos de violencia.

'Es fundamental que nuestro personal sepa cómo contener a las víctimas en los primeros momentos de una crisis, ya que esto puede marcar una gran diferencia en su recuperación posterior', explicó la coordinadora del programa.

Los participantes aprendieron técnicas de contención emocional, identificación de signos de estrés agudo y protocolos de derivación a equipos especializados. El curso incluye una certificación oficial y formará parte de la capacitación permanente del personal policial.",
        author: "Carlos Gómez",
        category_id: get_category_id(categories, "capacitacion-policial"),
        image_url: "/images/demo/psychological-training.jpg"
      },
      %{
        title: "Oficiales completan especialización en ciberdelitos",
        content:
          "Veinte oficiales de la Policía de Río Negro completaron con éxito el curso de especialización en 'Investigación de Delitos Informáticos', dictado por expertos nacionales e internacionales en la materia.

La capacitación, que se extendió durante tres meses, abordó temas como el análisis forense digital, la recolección de evidencia electrónica, técnicas de investigación en redes sociales y la dark web, así como los aspectos legales relacionados con los ciberdelitos.

'En un mundo cada vez más digitalizado, es imprescindible contar con personal altamente capacitado para enfrentar las nuevas modalidades delictivas', destacó el director de la División Cibercrimen durante la entrega de certificados.

Los oficiales capacitados se incorporarán a la recientemente creada Unidad Especializada en Delitos Informáticos, que atenderá casos de fraudes electrónicos, acoso cibernético, pornografía infantil, suplantación de identidad y otros delitos relacionados con las tecnologías digitales.",
        author: "María Fernanda López",
        category_id: get_category_id(categories, "capacitacion-policial"),
        image_url: "/images/demo/cybercrime-training.jpg"
      },

      # Seguridad Vial (3 artículos)
      %{
        title:
          "Nuevo radar móvil detecta 200 infracciones de velocidad en su primer fin de semana",
        content:
          "El nuevo sistema de radar móvil incorporado por la División Tránsito detectó 200 infracciones por exceso de velocidad durante su primer fin de semana de funcionamiento en la Ruta Provincial 40.

El dispositivo, que utiliza tecnología láser de última generación, puede medir la velocidad de los vehículos con un margen de error mínimo y capturar imágenes de alta definición incluso en condiciones climáticas adversas.

'El objetivo no es recaudatorio sino preventivo', aclaró el director de Seguridad Vial. 'Queremos generar conciencia sobre los peligros de la alta velocidad, que sigue siendo una de las principales causas de siniestros fatales'.

Las infracciones registradas implican multas que van desde los 20.000 hasta los 100.000 pesos, dependiendo del porcentaje de exceso sobre la velocidad máxima permitida. El radar continuará operando en diferentes puntos críticos de la red vial provincial.",
        author: "División Tránsito",
        category_id: get_category_id(categories, "seguridad-vial"),
        image_url: "/images/demo/speed-radar.jpg"
      },
      %{
        title: "Capacitan a motociclistas en técnicas de conducción segura",
        content:
          "Más de 100 motociclistas participaron de la jornada 'Dos Ruedas Seguras', donde recibieron capacitación teórica y práctica sobre técnicas de conducción segura y manejo defensivo.

El evento, organizado por la División Seguridad Vial, incluyó circuitos de habilidad, simulacros de situaciones de riesgo y demostraciones de uso correcto del equipamiento de seguridad.

'Los motociclistas representan más del 40% de las víctimas fatales en siniestros viales, por lo que es fundamental reforzar la capacitación en este grupo', señaló el oficial instructor del curso.

Además de la capacitación, los participantes recibieron chalecos reflectivos y pudieron realizar una verificación técnica gratuita de sus vehículos. El programa continuará con jornadas similares en otras localidades de la provincia durante los próximos meses.",
        author: "Jorge Mendoza",
        category_id: get_category_id(categories, "seguridad-vial"),
        image_url: "/images/demo/motorcycle-training.jpg"
      },
      %{
        title: "Campaña 'Alcohol Cero al Volante' intensifica controles nocturnos",
        content:
          "La campaña 'Alcohol Cero al Volante' ha intensificado los controles de alcoholemia en horarios nocturnos y zonas de concentración de locales gastronómicos y de entretenimiento.

Durante el último fin de semana, se realizaron más de 500 test de alcoholemia en diferentes puntos de la ciudad, detectándose 45 conductores que superaban el límite permitido, a quienes se les retuvo la licencia y el vehículo.

'Los controles son aleatorios y rotativos, y se complementan con una fuerte campaña de concientización', informó el comisario a cargo del operativo. La iniciativa incluye también la distribución de alcoholímetros descartables en bares y restaurantes, para que los conductores puedan autoevaluarse antes de tomar la decisión de conducir.

Las estadísticas locales muestran que el alcohol está presente en al menos el 30% de los siniestros viales con víctimas fatales, cifra que aumenta al 50% durante los fines de semana.",
        author: "Gabriela Medina",
        category_id: get_category_id(categories, "seguridad-vial"),
        image_url: "/images/demo/sobriety-checkpoint.jpg"
      },

      # Noticias Institucionales (3 artículos)
      %{
        title: "Asume nuevo Jefe de la Policía Provincial",
        content:
          "El Comisario General Roberto Benítez asumió hoy formalmente como nuevo Jefe de la Policía de Río Negro, en una ceremonia realizada en Casa de Gobierno con la presencia de autoridades provinciales.

Benítez, con 32 años de servicio en la institución, se desempeñaba anteriormente como Director General de Seguridad y cuenta con formación especializada en gestión policial y seguridad ciudadana.

'Asumo este cargo con el compromiso de continuar modernizando nuestra institución y fortalecer el vínculo con la comunidad', expresó el nuevo jefe durante su discurso. 'La seguridad es un trabajo conjunto entre la policía y los ciudadanos'.

Entre los principales desafíos de su gestión, Benítez mencionó la implementación del nuevo plan estratégico de seguridad provincial, la continuidad de la renovación tecnológica y el refuerzo de la formación continua del personal policial.",
        author: "Dirección de Prensa",
        category_id: get_category_id(categories, "noticias-institucionales"),
        image_url: "/images/demo/police-chief.jpg"
      },
      %{
        title: "Policía provincial celebra su 60º aniversario",
        content:
          "La Policía de Río Negro celebró hoy su 60º aniversario con un acto central en la plaza principal de la capital provincial, donde se realizó un desfile de efectivos y unidades especiales.

Durante la ceremonia, presidida por el Gobernador y el Ministro de Seguridad, se entregaron reconocimientos a oficiales destacados por su trayectoria y acciones meritorias, y se realizó un homenaje a los efectivos caídos en cumplimiento del deber.

'Sesenta años de historia nos posicionan como una institución madura, con experiencia y capacidad para adaptarse a los nuevos desafíos de la seguridad', expresó el Jefe de Policía en su discurso.

Como parte de las celebraciones, se inauguró una muestra fotográfica histórica en el Museo Provincial y se presentó un libro que recorre las seis décadas de la institución. Los festejos continuarán durante toda la semana con jornadas de puertas abiertas y actividades deportivas.",
        author: "Secretaría de Comunicación",
        category_id: get_category_id(categories, "noticias-institucionales"),
        image_url: "/images/demo/police-anniversary.jpg"
      },
      %{
        title: "Policía de Río Negro firma convenio de cooperación internacional",
        content:
          "La Policía de Río Negro firmó hoy un importante convenio de cooperación con la Policía Nacional de España para el intercambio de experiencias, capacitación y asistencia técnica en diversas áreas.

El acuerdo, que tendrá una vigencia de cuatro años, incluye programas de formación conjunta, intercambio de oficiales, colaboración en investigaciones transnacionales y cooperación tecnológica.

'Este convenio nos permitirá acceder a las mejores prácticas internacionales y fortalecer nuestras capacidades institucionales', destacó el Jefe de Policía durante la firma del acuerdo, que contó con la presencia del Embajador de España.

Entre los primeros proyectos a implementar se encuentra un programa de capacitación en técnicas avanzadas de investigación criminal, un sistema de intercambio de información sobre nuevas modalidades delictivas y un proyecto de modernización de la gestión policial.",
        author: "Oficina de Relaciones Internacionales",
        category_id: get_category_id(categories, "noticias-institucionales"),
        image_url: "/images/demo/international-agreement.jpg"
      }
    ]

    # Insertar artículos
    Enum.each(articulos, fn article_data ->
      %Article{}
      |> Article.changeset(article_data)
      |> Repo.insert(on_conflict: :nothing)
    end)
  end

  # Función auxiliar para obtener el ID de una categoría por su slug
  defp get_category_id(categories, slug) do
    case Map.get(categories, slug) do
      nil -> nil
      category -> category.id
    end
  end
end
