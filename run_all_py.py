import main
import asyncio
import script_connexion_RDS
import bronze_downloader

if __name__ == "__main__":
    print("DÉMARRAGE DU PIPELINE COMPLET (END-TO-END)")

    asyncio.run(bronze_downloader.run())
    
    main.run()
    script_connexion_RDS.run()

    print("S3 est propre et RDS est rempli !")